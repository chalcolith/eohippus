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
  let paths_to_search:
    Array[(String, (((ast.Node | None), Scope val ) | None))] =
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
    scope': Scope val)
  =>
    // find array index and update data
    for (i, pending) in paths_to_search.pairs() do
      if pending._1 == canonical_path' then
        try
          paths_to_search(i)? = (canonical_path', (syntax_tree', scope'))
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
      if paths_to_search.size() > 0 then
        // is there data in the first item in the array?
        match try paths_to_search(0)? end
        | (let cp: String, (let st: ast.Node, let sc: Scope val)) =>
          if cp == canonical_path then
            // this is our original file
            match _find_definition_span(st)
            | let span': String =>
              span = span'
              _find_definition_location(sc where orig_file = true)
            else
              finished = true
              notify.definition_failed(task_id, "span not found")
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
      if _is_in_range(l, c, nl, nc) then
        match node
        | let id: ast.NodeWith[ast.Identifier] =>
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
      end
    end

  fun _is_in_range(l: USize, c: USize, nl: USize, nc: USize): Bool =>
    if (line >= l) and (line <= nl) then
      if (line == l) and (line < nl) then
        column >= c
      elseif (line > l) and (line <= nl) then
        true
      elseif (line > l) and (line == nl) then
        column <= nc
      elseif (line == l) and (line == nl) then
        (column >= c) and (column <= nc)
      else
        false
      end
    else
      false
    end

  fun ref _find_definition_location(scope: Scope val, orig_file: Bool) =>
    var scope': (Scope val | None) =
      if orig_file then
        _find_child_scope(scope)
      else
        scope
      end
    while true do
      match scope'
      | let cur_scope: Scope val =>
        for definition in cur_scope.definitions.values() do
          if definition._1 == span then
            log(Fine) and log.log(
              task_id.string() + ": found definition for '" + span + "': "
              + cur_scope.canonical_path + ": " + definition._2._1.string()
              + ":" + definition._2._2.string() + "-"
              + definition._2._3.string() + ":" + definition._2._4.string())
            finished = true
            notify.definition_found(
              task_id, cur_scope.canonical_path, definition._2)
            break
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

  fun _find_child_scope(scope: Scope val): (Scope val | None) =>
    if
      _is_in_range(
        scope.range._1, scope.range._2, scope.range._3, scope.range._4)
    then
      for child in scope.children.values() do
        match _find_child_scope(child)
        | let scope': Scope val =>
          return scope'
        end
      end
      scope
    end
