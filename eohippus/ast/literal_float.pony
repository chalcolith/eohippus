use json = "../json"

class val LiteralFloat is NodeDataWithValue[LiteralFloat, F64]
  let _value: F64

  new val create(value': F64) =>
    _value = value'

  fun name(): String => "LiteralFloat"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    this

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    props.push(("value", _value))

  fun value(): F64 => _value

primitive ParseLiteralFloat
  fun apply(obj: json.Object, children: NodeSeq): (LiteralFloat | String) =>
    let value =
      match try obj("value")? end
      | let float: F64 =>
        float
      | let int: I128 =>
        F64.from[I128](int)
      else
        return "LiteralFloat.value must be a float"
      end
    LiteralFloat(value)
