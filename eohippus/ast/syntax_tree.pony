use "itertools"
use col = "collections"
use per = "collections/persistent"

use json = "../json"
use parser = "../parser"
use ".."

type LineColumnMap is col.MapIs[Node box, (USize, USize)] val
type Path is per.List[Node]

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

  fun tag traverse[S](visitor: Visitor[S], node: Node): Node =>
    _traverse[S](visitor, node, per.Cons[Node](node, per.Nil[Node]))

  fun tag _traverse[S](visitor: Visitor[S], node: Node, path: Path): Node =>
    let node_state = visitor.visit_pre(node, path)
    if node.children().size() == 0 then
      visitor.visit_post(consume node_state, node, path)
    else
      var new_children: (Array[Node] trn | None) = None

      var i: USize = 0
      while i < node.children().size() do
        try
          let child = node.children()(i)?
          let new_child: Node =
            _traverse[S](visitor, child, path.prepend(child))
          match new_children
          | let arr: Array[Node] trn =>
            arr.push(new_child)
          | None =>
            if new_children isnt child then
              let new_children': Array[Node] trn =
                Array[Node](node.children().size())
              if i > 0 then
                var j: USize = 0
                while j < (i-1) do
                  new_children'(j)? = node.children()(j)?
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
        visitor.visit_post(consume node_state, node, path, consume arr)
      else
        visitor.visit_post(consume node_state, node, path, node.children())
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

  fun ref visit_pre(node: Node, path: Path): State^
    """
      Returns an intermediate state value for use when constructing the new
      node.
    """

  fun ref visit_post(
    pre_state: State^,
    node: Node,
    path: Path,
    new_children: (NodeSeq | None) = None)
    : Node
    """
      Returns a new node constructed from the "pre" state (the intermediate
      state) that was returned by `visit_pre()`, and the new children itself.
    """
