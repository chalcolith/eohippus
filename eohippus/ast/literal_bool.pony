use json = "../json"

class val LiteralBool is NodeDataWithValue[LiteralBool, Bool]
  let _value: Bool

  new val create(value': Bool) =>
    _value = value'

  fun name(): String => "LiteralBool"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    this

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("value", _value))

  fun value(): Bool => _value

primitive ParseLiteralBool
  fun apply(obj: json.Object, children: NodeSeq): (LiteralBool | String) =>
    let value =
      match try obj("value")? end
      | let bool: Bool =>
        bool
      else
        return "LiteralBool.value must be a boolean"
      end
    LiteralBool(value)
