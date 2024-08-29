use "collections"
use json = "../json"

trait val NodeData
  """
    Contains strongly-typed data for various AST nodes.
  """

  fun name(): String
    """An informative identifier for the type of data the AST node holds."""

  fun add_json_props(node: Node box, props: Array[(String, json.Item)])
    """Add properties to the JSON representation of the AST node."""

  fun val clone(update_map: ChildUpdateMap): NodeData
    """
      Clone the strongly-typed data during a syntax tree transformation.
    """

  fun val _map[T: NodeData val](
    anciliary: NodeSeqWith[T],
    update_map: ChildUpdateMap)
    : NodeSeqWith[T]
  =>
    """
      When cloning, we'll often need to update typed fields to reference
      updated children. This takes a list of the old typed children and
      returns a list of references to the equivalent new children.
    """
    var result: Array[NodeWith[T]] trn = Array[NodeWith[T]](anciliary.size())
    for child in anciliary.values() do
      match try update_map(child)? as NodeWith[T] end
      | let node: NodeWith[T] =>
        result.push(node)
      end
    end
    consume result

  fun val _map_with[T: NodeData val](
    node: NodeWith[T],
    update_map: ChildUpdateMap)
    : NodeWith[T]
  =>
    """
      When cloning, we'll often need to update typed fields to reference updated
      children. This takes an original child (that was obligatory) and returns
      the equivalent updated child or the original if not found.
    """
    try
      update_map(node)? as NodeWith[T]
    else
      node
    end

  fun val _map_or_none[T: NodeData val](
    node: (NodeWith[T] | None),
    update_map: ChildUpdateMap)
    : (NodeWith[T] | None)
  =>
    """
      When cloning, we'll often need to update typed fields to reference updated
      children. This takes an optional original child and returns the equivalent
      updated child or the original if not found.
    """
    match node
    | let node': NodeWith[T] =>
      try update_map(node') as NodeWith[T] else node' end
    end

trait val NodeDataWithValue[D: NodeData val, V: Any val] is NodeData
  """The literal value of an AST node (i.e. a boolean or numeric literal)."""
  fun value(): V
