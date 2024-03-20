primitive NodeChild
  """
    Contains utilities for building new child arrays from old nodes when
    traversing the AST.
  """

  fun apply(old_child: Node, old_children: NodeSeq, new_children: NodeSeq)
    : Node ?
  =>
    """
      Finds the appropriate replacement in `new_children` for an `old_child`
      appearing in `old_children`.
    """
    var i: USize = 0
    while i < old_children.size() do
      if old_child is old_children(i)? then
        return new_children(i)?
      end
      i = i + 1
    end
    error

  fun child_with[T: NodeData val](
    old_child: NodeWith[T],
    old_children: NodeSeq,
    new_children: NodeSeq)
    : NodeWith[T] ?
  =>
    """
      Finds the appropriate replacement in `new_children` for an `old_child`
      appearing in `old_children`.
    """
    var i: USize = 0
    while i < old_children.size() do
      if old_child is old_children(i)? then
        return new_children(i)? as NodeWith[T]
      end
      i = i + 1
    end
    error

  fun or_none(
    old_child: (Node | None),
    old_children: NodeSeq,
    new_children: NodeSeq)
    : (Node | None) ?
  =>
    """
      Finds the appropriate replacement (or `None`) in `new_children` for an
      `old_child` appearing in `old_children`.
    """
    match old_child
    | let old_child': Node =>
      var i: USize = 0
      while i < old_children.size() do
        if old_child' is old_children(i)? then
          return new_children(i)?
        end
        i = i + 1
      end
    end
    None

  fun with_or_none[T: NodeData val](
    old_typed_child: (NodeWith[T] | None),
    old_children: NodeSeq,
    new_children: NodeSeq)
    : (NodeWith[T] | None) ?
  =>
    """
      Finds the appropriate replacement (or `None`) in `new_children` for an
      `old_child` appearing in `old_children`.
    """
    match old_typed_child
    | let old_typed_child': NodeWith[T] =>
      var i: USize = 0
      while i < old_children.size() do
        if old_typed_child' is old_children(i)? then
          return new_children(i)? as NodeWith[T]
        end
        i = i + 1
      end
    end
    None

  fun seq_with[T: NodeData val](
    old_typed_children: NodeSeqWith[T],
    old_children: NodeSeq,
    new_children: NodeSeq)
    : NodeSeqWith[T] ?
  =>
    """
      If we have an old list of typed children (from node data), some of which
      are found in `old_children`, this method builds a new list of typed
      children from the equivalents in `new_children`.  `old_children` and
      `new_children` must have the same number of elements, and each element
      in `new_children` must be the (possibly updated) equivalent to its
      corresponding element in `old_children`.
    """
    if old_typed_children.size() == 0 then
      return old_typed_children
    end
    if old_children.size() != new_children.size() then
      error
    end
    let result: Array[NodeWith[T]] trn = Array[NodeWith[T]](
      old_typed_children.size())
    for old_typed_child in old_typed_children.values() do
      var i: USize = 0
      while i < old_children.size() do
        if old_typed_child is old_children(i)? then
          result.push(new_children(i)? as NodeWith[T])
          break
        end
        i = i + 1
      end
    end
    consume result
