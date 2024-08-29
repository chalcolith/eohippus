use json = "../json"

class val Span is NodeData
  """A span of source code without further semantic meaning."""

  new create() =>
    None

  fun name(): String => "Span"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    this

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    None

primitive ParseSpan
  fun apply(obj: json.Object, children: NodeSeq): (Span | String) =>
    recover Span end
