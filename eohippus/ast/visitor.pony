interface Visitor[State: Any #read]
  """
    Used to effect transformations of an AST, using `SyntaxTree.traverse()`.

    AST trees are immutable.  We get a transformed tree by traversing the old
    tree and returning a new one (re-using unmodified nodes as necessary).

    Traversal happens in the following fashion:

    - For a node (starting with the root):
      - Call `visit_pre()` on the visitor with a parent state; this returns an
        intermediate state (if some data needs to be saved for later).
      - Build a list of new node children by calling `traverse()` on each old
        child, passing the parent state (but not the intermediate state).
      - Call `visit_post()` with the parent state and the intermediate state,
        the old children of the node, and the new children.
        `visit_post()` then returns a (possibly modified) parent_state (for
        passing to the node's further siblings), and the new node.
  """

  fun ref visit_pre(
    parent_state: State,
    node: Node,
    path: Path,
    errors: Array[TraverseError] iso)
    : (State, Array[TraverseError] iso^)
    """
      Returns an intermediate state value for use when constructing the new
      node.
    """

  fun ref visit_post(
    parent_state: State,
    node_state: State,
    node: Node,
    path: Path,
    errors: Array[TraverseError] iso,
    new_children: (NodeSeq | None) = None,
    update_map: (ChildUpdateMap | None) = None)
    : (State, (Node | None), Array[TraverseError] iso^)
    """
      Returns a new node constructed from the "pre" state (the intermediate
      state) that was returned by `visit_pre()`, and the new children.

      Even if no other processing is needed, make sure to clone the node if
      `new_children` and `update_map` exist.
    """