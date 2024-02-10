use "itertools"
use per = "collections/persistent"

use json = "../json"
use parser = "../parser"
use ".."

primitive SyntaxTree
  fun tag traverse[State](visitor: Visitor[State], root: Node): Node =>
    """
      Traverse an AST and return a transformed tree.
    """
    _traverse[State](visitor, per.Cons[Node](root, per.Nil[Node]))

  fun tag _traverse[State](
    visitor: Visitor[State],
    node: Node,
    path: per.List[Node])
    : Node
  =>
    let node_state = visitor.visit_pre(node, path)
    if node.children().size() == 0 then
      visitor.visit_post(consume node_state, node, path)
    else
      let new_children: Array[Node] trn =
        Array[Node](node.children().size())
      for child in node.children().values() do
        new_children.push(_traverse[State](visitor, child, path.prepend(child)))
      end
      visitor.visit_post(consume node_state, node, path, consume new_children)
    end

  fun tag set_line_info(root: Node): (Node, ReadSeq[parser.Loc]) =>
    """
      Takes an AST without line and column info, and returns a transformed
      tree that includes line and column info (obtained by tracking newlines).
    """
    let visitor = _SetLineVisitor(
      root.src_info().locator, root.src_info().start.segment())
    let result = traverse[_SetLineState](visitor, root)
    (result, visitor.line_beginnings)

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

  fun ref visit_pre(node: Node, path: per.List[Node]): State^
    """
      Returns an intermediate state value for use when constructing the new
      node.
    """

  fun ref visit_post(
    pre_state: State^,
    node: Node,
    path: per.List[Node],
    new_children: (NodeSeq | None) = None)
    : Node
    """
      Returns a new node constructed from the "pre" state (the intermediate
      state) that was returned by `visit_pre()`, and the new children itself.
    """

class _SetLineState
  let locator: parser.Locator
  let segment: parser.Segment
  let line: USize
  let column: USize

  new create(
    locator': parser.Locator,
    segment': parser.Segment,
    line': USize,
    column': USize)
  =>
    locator = locator'
    segment = segment'
    line = line'
    column = column'

class _SetLineVisitor is Visitor[_SetLineState]
  let line_beginnings: Array[parser.Loc]
  var locator: parser.Locator
  var segment: parser.Segment
  var line: USize
  var column: USize

  new create(locator': parser.Locator, segment': parser.Segment) =>
    line_beginnings = Array[parser.Loc]
    locator = locator'
    segment = segment'
    line = 0
    column = 0

  fun ref visit_pre(node: Node, path: per.List[Node]): _SetLineState =>
    let si = node.src_info()

    // check for locator or segment changes
    if si.locator != locator then
      locator = si.locator
      segment = si.start.segment()
      line = 0
      column = 0
    elseif si.start.segment() isnt segment then
      segment = si.start.segment()
    end

    let node_state = _SetLineState(locator, segment, line, column)

    // check for line and column changes
    match node
    | let eol: NodeWith[Trivia] if eol.data().kind is EndOfLineTrivia =>
      if line_beginnings.size() == 0 then
        line_beginnings.push(si.start)
      end
      line_beginnings.push(si.next)
      line = line + 1
      column = 0
    else
      if node.children().size() == 0 then
        if line_beginnings.size() == 0 then
          line_beginnings.push(si.start)
        end
        column = column + si.length()
      end
    end

    node_state

  fun ref visit_post(
    pre_state: _SetLineState,
    node: Node,
    path: per.List[Node],
    new_children: (NodeSeq | None) = None)
    : Node
  =>
    let new_src_info = SrcInfo.from(node.src_info()
      where line' = pre_state.line, column' = pre_state.column)
    try
      if node.children().size() == 0 then
        node.clone(where src_info' = new_src_info)?
      else
        node.clone(where
          src_info' = new_src_info,
          old_children' = node.children(),
          new_children' = new_children)?
      end
    else
      let message = ErrorMsg.internal_ast_pass_clone()
      NodeWith[ErrorSection](
        new_src_info, node.children(), ErrorSection(message))
    end
