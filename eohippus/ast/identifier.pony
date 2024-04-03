use json = "../json"

class val Identifier is NodeData
  let string: String

  new val create(string': String) =>
    string = string'

  fun name(): String => "Identifier"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    this

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("string", string))
