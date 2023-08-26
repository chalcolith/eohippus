use json = "../json"

class val Identifier is NodeData
  let string: String

  new val create(string': String) =>
    string = string'

  fun name(): String => "Identifier"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("string", string))
