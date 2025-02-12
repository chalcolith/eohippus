use json = "../json"

class val Identifier is NodeData
  let string: String

  new val create(string': String) =>
    string = string'

  fun name(): String => "Identifier"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    this

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    props.push(("string", string))

primitive ParseIdentifier
  fun apply(obj: json.Object val, children: NodeSeq): (Identifier | String) =>
    let string =
      match try obj("string")? end
      | let s: String box =>
        s
      else
        return "Identifier.string must be a string"
      end
    Identifier(string.clone())
