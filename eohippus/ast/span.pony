use json = "../json"

class val Span is NodeData
  """A span of source code without further semantic meaning."""

  new create() =>
    None

  fun name(): String => "Span"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData =>
    this

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    None
