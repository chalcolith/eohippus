use "itertools"
use col = "collections"
use per = "collections/persistent"

use json = "../json"
use parser = "../parser"
use ".."

class SyntaxTree
  var root: Node
  let line_beginnings: Array[parser.Loc]
  let lines_and_columns: col.MapIs[Node, (USize, USize)]

  new create(root': Node, update_lines: Bool = true) =>
    root = root'
    line_beginnings = Array[parser.Loc]
    lines_and_columns = col.MapIs[Node, (USize, USize)]
    if update_lines then
      update_line_info()
    end

  fun ref traverse[S](visitor: Visitor[S], update_lines: Bool = true) =>
    root = _traverse[S](visitor, root)
    if update_lines then
      update_line_info()
    end

  fun ref _traverse[S](visitor: Visitor[S], node: Node): Node =>
    let node_state = visitor.visit_pre(node)
    if node.children().size() == 0 then
      visitor.visit_post(consume node_state, node)
    else
      let new_children: Array[Node] trn =
        Array[Node](node.children().size())
      for child in node.children().values() do
        new_children.push(_traverse[S](visitor, child))
      end
      visitor.visit_post(consume node_state, node, consume new_children)
    end

  fun ref update_line_info() =>
    line_beginnings.clear()
    lines_and_columns.clear()
    _update_line_info(
      root,
      _UpdateLineState(
        root.src_info().locator, root.src_info().start.segment()))

  fun ref _update_line_info(node: Node, state: _UpdateLineState) =>
    let si = node.src_info()
    if si.locator != state.locator then
      state.locator = si.locator
      state.segment = si.start.segment()
      state.line = 0
      state.column = 0
    end

    lines_and_columns(node) = (state.line, state.column)

    match node
    | let eol: NodeWith[Trivia] if eol.data().kind is EndOfLineTrivia =>
      if line_beginnings.size() == 0 then
        line_beginnings.push(si.start)
      end
      line_beginnings.push(si.next)
      state.line = state.line + 1
      state.column = 0
    else
      if node.children().size() == 0 then
        if line_beginnings.size() == 0 then
          line_beginnings.push(si.start)
        end
        state.column = state.column + si.length()
      end
    end

    for child in node.children().values() do
      _update_line_info(child, state)
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

interface Visitor[State]
  """
    Used to effect transformations of an AST, using `SyntaxTree.traverse()`.

    AST trees are immutable.  We get a transformed tree by traversing the old
    tree and returning a new one (re-using unmodified nodes as necessary).

    Traversal happens in the following fashion:

    - For a node (starting with the root):
      - Call `visit_pre()` on the visitor; this returns an intermediate state
        (if some data needs to be saved for later).
      - Build a list of new node children by calling `traverse()` on each old
        child.
      - Call `visit_post()` with the intermediate saved state, the old children
        of the node, and the new children. `visit_post()` returns the new node.
  """

  fun ref visit_pre(node: Node): State^
    """
      Returns an intermediate state value for use when constructing the new
      node.
    """

  fun ref visit_post(
    pre_state: State^,
    node: Node,
    new_children: (NodeSeq | None) = None)
    : Node
    """
      Returns a new node constructed from the "pre" state (the intermediate
      state) that was returned by `visit_pre()`, and the new children itself.
    """
