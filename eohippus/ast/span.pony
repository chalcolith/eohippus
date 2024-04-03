use json = "../json"

class val Span is NodeData
  """A span of source code without further semantic meaning."""

  new create() =>
    None

  fun name(): String => "Span"

  fun val clone(updates: ChildUpdateMap): Span =>
    this

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    None
