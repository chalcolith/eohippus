use "collections"
use "logger"

use ast = "../../ast"
use ".."

interface tag FindDefinitionNotify
  be definition_found(
    task_id: USize,
    canonical_path: String,
    range: SrcRange)
  be definition_failed(
    task_id: USize,
    message: String)

class SearchFileItem
  let canonical_path: String
  let syntax_tree: (ast.Node | None)
  let nodes_by_index: Map[USize, ast.Node] val
  let scope: Scope

  new create(
    canonical_path': String,
    syntax_tree': (ast.Node | None),
    nodes_by_index': Map[USize, ast.Node] val,
    scope': Scope)
  =>
    canonical_path = canonical_path'
    syntax_tree = syntax_tree'
    nodes_by_index = nodes_by_index'
    scope = scope'

actor FindDefinition is AnalyzerRequestNotify
  // we keep an ordered list of paths to search, starting with the original one
  // when they come in from the analyzer, we see if the first one is done
  let log: Logger[String]
  let analyzer: Analyzer
  let task_id: USize
  let canonical_path: String
  let line: USize
  let column: USize
  let notify: FindDefinitionNotify

  var span: String = "!INVALID!"
  let paths_to_search: Array[(String, (SearchFileItem | None))] =
    paths_to_search.create()
  var finished: Bool = false

  new create(
    log': Logger[String],
    analyzer': Analyzer,
    task_id': USize,
    canonical_path': String,
    line': USize,
    column': USize,
    notify': FindDefinitionNotify)
  =>
    log = log'
    analyzer = analyzer'
    task_id = task_id'
    canonical_path = canonical_path'
    line = line'
    column = column'
    notify = notify'

    paths_to_search.push((canonical_path, None))
    analyzer.request_info(task_id, canonical_path, this)

  be request_succeeded(
    task_id': USize,
    canonical_path': String,
    syntax_tree': (ast.Node | None),
    nodes_by_index': Map[USize, ast.Node] val,
    scope': Scope val)
  =>
    // find array index and update data
    for (i, pending) in paths_to_search.pairs() do
      if pending._1 == canonical_path' then
        try
          let item = SearchFileItem(
            canonical_path',
            syntax_tree',
            nodes_by_index',
            scope')
          paths_to_search(i)? = (canonical_path', item)
        end
      end
    end
    _process_next_path()

  be request_failed(
    task_id': USize,
    canonical_path': String,
    message': String)
  =>
    log(Error) and log.log(
      task_id'.string() + ": analysis request failed: " + message')

    for (i, pending) in paths_to_search.pairs() do
      if canonical_path' == pending._1 then
        try paths_to_search.delete(i)? end
        break
      end
    end

    // if there are no more pending requests, notify of failure
    if paths_to_search.size() == 0 then
      log(Error) and log.log(
        task_id'.string() + ": unable to find definition: " + message')
      finished = true
      notify.definition_failed(task_id', message')
    end

  fun ref _process_next_path() =>
    if not finished then
      // is there data in the first item in the array?
      match try paths_to_search(0)? end
      | (let cp: String, let sfi: SearchFileItem) =>
        if cp == canonical_path then
          match sfi.syntax_tree
          | let st: ast.Node =>
            // this is our original file
            match _find_definition_span(st)
            | let span': String =>
              span = span'
              _find_definition_location(sfi where orig_file = true)
            else
              finished = true
              notify.definition_failed(task_id, "span not found")
            end
          else
            finished = true
            notify.definition_failed(
              task_id, "no syntax tree for " + canonical_path)
          end
        else
          // we're in a sibling, or import, or builtin
          // if package scope, go into children
          // TODO:
          None
        end
        try
          paths_to_search.shift()?
        end
      else
        finished = true
        notify.definition_failed(task_id, "definition not found: " + span)
      end
    end

  fun ref _find_definition_span(node: ast.Node) : (String | None) =>
    let si = node.src_info()
    match (si.line, si.column, si.next_line, si.next_column)
    | (let l: USize, let c: USize, let nl: USize, let nc: USize) =>
      // log(Fine) and log.log(
      //   task_id.string() + ": " + canonical_path + ": is (" + line.string()
      //   + "," + column.string() + ") in " + node.name() + " (" + l.string()
      //   + "," + c.string() + ") - (" + nl.string() + "," + nc.string() + ")?")

      if _is_in_range(l, c, nl, nc) then
        // log(Fine) and log.log(
        //   task_id.string() + ": " + canonical_path + ": yes")
        match node
        | let id: ast.NodeWith[ast.Identifier] =>
          // log(Fine) and log.log(
          //   task_id.string() + ": " + canonical_path + ": found "
          //   + id.data().string + " (" + l.string() + "," + c.string() + ") - ("
          //   + nl.string() + "," + nc.string() + ")")
          return id.data().string
        end
        if node.children().size() > 0 then
          // TODO: do a binary search here
          for child in node.children().values() do
            match _find_definition_span(child)
            | let span': String =>
              return span'
            end
          end
        end
      else
        // log(Fine) and log.log(
        //   task_id.string() + ": " + canonical_path + ": no")
        None
      end
    end
    None

  fun _is_in_range(l: USize, c: USize, nl: USize, nc: USize): Bool =>
    if (line >= l) and (line <= nl) then
      if (line == nl) and (column <= nc) then
        return true
      elseif (line == l) and (line == nl) then
        return (column >= c) and (column < nc)
      elseif (line == l) and (line < nl) then
        return true
      elseif (line > l) and (line < nl) then
        return true
      end
    end
    false

  fun ref _find_definition_location(
    item: SearchFileItem,
    orig_file: Bool)
    : Bool
  =>
    let scope = item.scope
    var scope': (Scope val | None) =
      if orig_file then
        _find_child_scope(scope)
      else
        // log(Fine) and log.log(
        //   task_id.string() + ": original scope " + scope.name + "("
        //   + scope.range._1.string() + "," + scope.range._2.string() + ") - ("
        //   + scope.range._3.string() + "," + scope.range._4.string() + ")")
        scope
      end
    while true do
      match scope'
      | let cur_scope: Scope val =>
        // log(Fine) and log.log(
        //   task_id.string() + ": search scope " + cur_scope.name + " ("
        //   + cur_scope.range._1.string() + "," + cur_scope.range._2.string()
        //   + ") - (" + cur_scope.range._3.string() + ","
        //   + cur_scope.range._4.string() + ")")

        for defs in cur_scope.definitions.values() do
          for definition in defs.values() do
            let identifier = definition._2
            if identifier != span then
              continue
            end

            let node_index = definition._1
            let doc_string = definition._3

            match try item.nodes_by_index(node_index)? end
            | let node: ast.Node =>
              let si = node.src_info()
              match (si.line, si.column, si.next_line, si.next_column)
              | (let l: USize, let c: USize, let nl: USize, let nc: USize) =>
                log(Fine) and log.log(
                  task_id.string() + ": found definition for '" + span +
                  "': " + l.string() + ":" + c.string() + "-" + nl.string() +
                  ":" + nc.string())
                finished = true
                notify.definition_found(
                  task_id, cur_scope.canonical_path, (l, c, nl, nc))
                return true
              end
            end
          end
        end
        match cur_scope.kind
        | FileScope =>
          // TODO: add siblings, then imports, then builtin
          None
        end
        scope' = cur_scope.parent
      else
        break
      end
    end
    false

  fun _find_child_scope(scope: Scope val): (Scope val | None) =>
    if
      _is_in_range(
        scope.range._1, scope.range._2, scope.range._3, scope.range._4)
    then
      // log(Fine) and log.log(
      //   task_id.string() + ": drill into scope " + scope.name + " ("
      //   + scope.range._1.string() + "," + scope.range._2.string() + ") - ("
      //   + scope.range._3.string() + "," + scope.range._4.string() + ")")
      for child in scope.children.values() do
        match _find_child_scope(child)
        | let scope': Scope val =>
          return scope'
        end
      end
      // log(Fine) and log.log(
      //   task_id.string() + ": found scope " + scope.name + " ("
      //   + scope.range._1.string() + "," + scope.range._2.string() + ") - ("
      //   + scope.range._3.string() + "," + scope.range._4.string() + ")")
      scope
    end
