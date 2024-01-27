use "itertools"
use per = "collections/persistent"

use json = "../json"
use parser = "../parser"
use ".."

interface val Visitor[State: Any val]
  """
    Used to effect transformations of an AST, using `SyntaxTree.traverse()`.

    AST trees are immutable.  We get a transformed tree by traversing the old
    tree and returning a new one (re-using unmodified nodes as necessary).

    Traversal happens in the following fashion:

    - Get an initial visitor state.
    - For a node (starting with the root):
      - Call `visit_pre()`, with the current visitor state; this returns an
        intermediate state (if some data needs to be saved for later), and the
        next current visitor state.
      - Build a list of new node children by calling `traverse()` on each old
        child, passing the updated current state through each call.
      - Call `visit_post()` with the intermediate saved state, the old children
        of the node, and the new children, as well as the last "next" state
        returned from building the children. `visit_post()` should return the
        new node and a new current state.
  """

  fun val initial_state(): State

  fun val visit_pre(state: State, node: Node): (State, State)
    """
      Returns an intermediate state value for use when constructing the new
      node, as well as a current state value used to pass to traversing the
      child nodes.
    """

  fun val visit_post(
    pre_state: State,
    post_state: State,
    node: Node,
    new_children: (NodeSeq | None) = None)
    : (State, Node)
    """
      Returns a new node constructed from the "pre" state (the intermediate
      state) that was returned by `visit_pre()`, the "post" state from
      constructing the new children, and the new children itself.
    """

primitive SyntaxTree
  fun tag traverse[State: Any val](visitor: Visitor[State], root: Node): Node =>
    """
      Traverse an AST and return a transformed tree.
    """
    _traverse[State](visitor, visitor.initial_state(), root)._2

  fun tag _traverse[State: Any val](
    visitor: Visitor[State],
    state: State,
    node: Node)
    : (State, Node)
  =>
    (let pre_state, var next_state) = visitor.visit_pre(state, node)
    if node.children().size() == 0 then
      visitor.visit_post(pre_state, next_state, node)
    else
      let new_children: Array[Node] trn =
        Array[Node](node.children().size())
      for child in node.children().values() do
        (next_state, let new_child) =
          _traverse[State](visitor, next_state, child)
        new_children.push(new_child)
      end
      visitor.visit_post(pre_state, next_state, node, consume new_children)
    end

  fun tag set_line_info(root: Node): (Node, ReadSeq[parser.Loc]) =>
    """
      Takes an AST without line and column info, and returns a transformed
      tree that includes line and column info (obtained by tracking newlines).
    """
    let visitor = _SetLineVisitor(
      root.src_info().locator, root.src_info().start.segment())
    (let post_state, let result) = _traverse[_SetLineState](
      visitor, visitor.initial_state(), root)
    (result, post_state.lines.reverse())

class val _SetLineState
  let lines: per.List[parser.Loc]
  let locator: parser.Locator
  let segment: parser.Segment
  let line: USize
  let column: USize

  new val create(locator': parser.Locator, segment': parser.Segment) =>
    lines = per.Nil[parser.Loc]
    locator = locator'
    segment = segment'
    line = 0
    column = 0

  new val from(
    orig: _SetLineState,
    lines': (per.List[parser.Loc] | None) = None,
    locator': (parser.Locator | None) = None,
    segment': (parser.Segment | None) = None,
    line': (USize | None) = None,
    column': (USize | None) = None)
  =>
    locator =
      match locator'
      | let locator'': parser.Locator =>
        locator''
      else
        orig.locator
      end
    segment =
      match segment'
      | let segment'': parser.Segment =>
        segment''
      else
        orig.segment
      end
    lines =
      match lines'
      | let lines'': per.List[parser.Loc] =>
        lines''
      else
        orig.lines
      end
    line =
      match line'
      | let line'': USize =>
        line''
      else
        orig.line
      end
    column =
      match column'
      | let column'': USize =>
        column''
      else
        orig.column
      end

class val _SetLineVisitor is Visitor[_SetLineState]
  let _initial_state: _SetLineState

  new val create(locator': parser.Locator, segment': parser.Segment) =>
    _initial_state = _SetLineState(locator', segment')

  fun val initial_state(): _SetLineState => _initial_state

  fun val visit_pre(state: _SetLineState, node: Node)
    : (_SetLineState, _SetLineState)
  =>
    var new_locator: parser.Locator = state.locator
    var new_segment: parser.Segment = state.segment
    var new_lines: per.List[parser.Loc] = state.lines
    var new_line = state.line
    var new_column = state.column

    // reset state if necessary for new locator or segment
    if node.src_info().locator != state.locator then
      new_locator = node.src_info().locator
      new_segment = node.src_info().start.segment()
      new_line = 0
      new_column = 0
    elseif node.src_info().start.segment() isnt state.segment then
      new_segment = node.src_info().start.segment()
    end

    // save pre_state
    let pre_state = _SetLineState.from(
      state, new_lines, new_locator, new_segment, new_line, new_column)

    // check for line and column changes
    match node
    | let eol: NodeWith[Trivia] if eol.data().kind is EndOfLineTrivia =>
      if new_lines.size() == 0 then
        new_lines = new_lines.prepend(node.src_info().start)
      end
      new_lines = new_lines.prepend(node.src_info().next)
      new_line = new_line + 1
      new_column = 0
    else
      if node.children().size() == 0 then
        if new_lines.size() == 0 then
          new_lines = new_lines.prepend(node.src_info().start)
        end
        new_column = new_column + node.src_info().length()
      end
    end

    let next_state = _SetLineState.from(
      state, new_lines, new_locator, new_segment, new_line, new_column)

    (pre_state, next_state)

  fun val visit_post(
    pre_state: _SetLineState,
    post_state: _SetLineState,
    node: Node,
    new_children: (NodeSeq | None))
    : (_SetLineState, Node)
  =>
    let new_src_info = SrcInfo.from(node.src_info()
      where line' = pre_state.line, column' = pre_state.column)
    let new_node =
      try
        if node.children().size() == 0 then
          node.clone(where src_info' = new_src_info)?
        else
          node.clone(
            where
              src_info' = new_src_info,
              old_children' = node.children(),
              new_children' = new_children)?
        end
      else
        let message = ErrorMsg.internal_ast_pass_clone()
        NodeWith[ErrorSection](
          new_src_info, node.children(), ErrorSection(message))
      end
    (post_state, new_node)
