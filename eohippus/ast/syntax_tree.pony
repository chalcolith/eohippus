use "itertools"

use parser = "../parser"
use ".."

class SyntaxTree
  var _root: Node
  var _line_beginnings: Array[parser.Loc]

  new create(root': Node) =>
    _root = root'
    _line_beginnings = Array[parser.Loc]

  fun root(): Node => _root

  fun line_beginnings(): Array[parser.Loc] box => _line_beginnings

  fun ref set_line_info() =>
    let state = _SetLineState(
      _line_beginnings,
      _root.src_info().locator,
      _root.src_info().start.segment(),
      1,
      1
    )
    _root = _set_line_info(_root, None, state)

  fun ref _set_line_info(
    node: Node,
    parent: (Node | None),
    state: _SetLineState)
    : Node
  =>
    // reset state if necessary
    if node.src_info().locator != state.locator then
      state.locator = node.src_info().locator
      state.segment = node.src_info().start.segment()
      state.line = 1
      state.column = 1
    elseif node.src_info().start.segment() isnt state.segment then
      state.segment = node.src_info().start.segment()
    end

    // record line and column
    let line = state.line
    let column = state.column

    // check for line and column changes
    match node
    | let eol: NodeWith[Trivia] if eol.data().kind is EndOfLineTrivia =>
      if state.lines.size() == 0 then
        state.lines.push(node.src_info().start)
      end
      state.lines.push(node.src_info().next)

      state.line = state.line + 1
      state.column = 1
    else
      if (state.lines.size() == 0) and (node.children().size() == 0) then
        state.lines.push(node.src_info().start)
      end

      if node.children().size() == 0 then
        state.column = state.column + node.src_info().length()
      end
    end

    // collect children
    let new_children: Array[Node] trn =
      Array[Node](node.children().size())
    for child in node.children().values() do
      new_children.push(_set_line_info(child, node, state))
    end
    let new_src_info = SrcInfo.from(node.src_info()
      where line' = line, column' = column)

    try
      node.clone(
        where
          src_info' = new_src_info,
          old_children' = node.children(),
          new_children' = consume new_children)?
    else
      let message = ErrorMsg.internal_ast_pass_clone()
      NodeWith[ErrorSection](
        new_src_info, node.children(), ErrorSection(message))
    end

class _SetLineState
  let lines: Array[parser.Loc]
  var locator: parser.Locator
  var segment: parser.Segment
  var line: USize
  var column: USize

  new create(
    lines': Array[parser.Loc],
    locator': parser.Locator,
    segment': parser.Segment,
    line': USize,
    column': USize)
  =>
    lines = lines'
    locator = locator'
    segment = segment'
    line = line'
    column = column'
