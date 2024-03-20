use json = "../json"

trait val NodeData
  """
    Contains strongly-typed data for various AST nodes.
  """

  fun name(): String
    """An informative identifier for the type of data the AST node holds."""

  fun add_json_props(node: Node, props: Array[(String, json.Item)])
    """Add properties to the JSON representation of the AST node."""

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ?
    """Clone the data during a syntax tree traversal and transformation."""

trait val NodeDataWithValue[V: Any val] is NodeData
  """The literal value of an AST node (i.e. a boolean or numeric literal)."""
  fun value(): V
