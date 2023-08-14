use json = "../json"

class val DocString is NodeData
  let string: NodeWith[LiteralString]

  new val create(string': NodeWith[LiteralString]) =>
    string = string'

  fun name(): String => "DocString"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("string", string.get_json()))
