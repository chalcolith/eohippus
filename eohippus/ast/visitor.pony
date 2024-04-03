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

  fun ref visit_pre(node: Node, path: Path, errors: Array[TraverseError] iso)
    : (State^, Array[TraverseError] iso^)
    """
      Returns an intermediate state value for use when constructing the new
      node.
    """

  fun ref visit_post(
    pre_state: State^,
    node: Node,
    path: Path,
    errors: Array[TraverseError] iso,
    new_children: (NodeSeq | None) = None)
    : (Node, Array[TraverseError] iso^)
    """
      Returns a new node constructed from the "pre" state (the intermediate
      state) that was returned by `visit_pre()`, and the new children itself.
    """
