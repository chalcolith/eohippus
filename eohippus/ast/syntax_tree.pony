use "itertools"
use col = "collections"
use per = "collections/persistent"

use json = "../json"
use parser = "../parser"
use ".."

type LineColumnMap is col.MapIs[Node box, (USize, USize)] val
type Path is per.List[Node]
type TraverseError is (Node, String)

class SyntaxTree
  var root: Node val
  var line_beginnings: Array[parser.Loc] val
  var lines_and_columns: LineColumnMap

  new create(root': Node, update_lines: Bool = true) =>
    root = root'
    line_beginnings = Array[parser.Loc]
    lines_and_columns = col.MapIs[Node box, (USize, USize)]
    if update_lines then
      update_line_info()
    end

  fun tag traverse[S](visitor: Visitor[S], node: Node)
    : (Node, ReadSeq[TraverseError] val)
  =>
    var errors: Array[TraverseError] iso = Array[TraverseError]
    (let new_node, errors) = _traverse[S](
      visitor,
      node,
      per.Cons[Node](node, per.Nil[Node]),
      consume errors)
    (new_node, consume errors)

  fun tag _traverse[S](
    visitor: Visitor[S],
    node: Node,
    path: Path,
    errors: Array[TraverseError] iso)
    : (Node, Array[TraverseError] iso^)
  =>
    var errors': Array[TraverseError] iso = consume errors
    (let node_state, errors') = visitor.visit_pre(node, path, consume errors')
    if node.children().size() == 0 then
      (let result, errors') = visitor.visit_post(
        consume node_state, node, path, consume errors')
      (result, consume errors')
    else
      var new_children: (Array[Node] trn | None) = None
      var i: USize = 0
      while i < node.children().size() do
        try
          let child = node.children()(i)?
          (let new_child, errors') = _traverse[S](
            visitor, child, path.prepend(child), consume errors')
          match new_children
          | let arr: Array[Node] trn =>
            arr.push(new_child)
          | None =>
            if new_child isnt child then
              let new_children': Array[Node] trn =
                Array[Node](node.children().size())
              if i > 0 then
                var j: USize = 0
                while j < i do
                  new_children'.push(node.children()(j)?)
                  j = j + 1
                end
              end
              new_children'.push(new_child)
              new_children = consume new_children'
            end
          end
        end
        i = i + 1
      end

      match new_children
      | let arr: Array[Node] trn =>
        (let result, errors') = visitor.visit_post(
            consume node_state, node, path, consume errors', consume arr)
        (result, consume errors')
      else
        (let result, errors') = visitor.visit_post(
            consume node_state, node, path, consume errors', node.children())
        (result, consume errors')
      end
    end

  fun ref update_line_info() =>
    (line_beginnings, lines_and_columns) =
      recover val
        let lb = Array[parser.Loc]
        let lc = col.MapIs[Node box, (USize, USize)]

        _update_line_info(
          root,
          _UpdateLineState(
            root.src_info().locator, root.src_info().start.segment()),
          lb,
          lc)

        (lb, lc)
      end

  fun tag _update_line_info(
    node: Node,
    state: _UpdateLineState,
    lb: Array[parser.Loc],
    lc: col.MapIs[Node box, (USize, USize)])
  =>
    let si = node.src_info()
    if si.locator != state.locator then
      state.locator = si.locator
      state.segment = si.start.segment()
      state.line = 0
      state.column = 0
    end

    lc(node) = (state.line, state.column)

    match node
    | let eol: NodeWith[Trivia] if eol.data().kind is EndOfLineTrivia =>
      if lb.size() == 0 then
        lb.push(si.start)
      end
      lb.push(si.next)
      state.line = state.line + 1
      state.column = 0
    else
      if node.children().size() == 0 then
        if lb.size() == 0 then
          lb.push(si.start)
        end
        state.column = state.column + si.length()
      end
    end

    for child in node.children().values() do
      _update_line_info(child, state, lb, lc)
    end

class _UpdateLineState
  var locator: parser.Locator
  var segment: parser.Segment
  var line: USize
  var column: USize

  new create(
    locator': parser.Locator,
    segment': parser.Segment)
  =>
    locator = locator'
    segment = segment'
    line = 0
    column = 0
