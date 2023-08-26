use json = "../json"

class val Span is NodeData
  new create() =>
    None

  fun name(): String => "Span"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    None
