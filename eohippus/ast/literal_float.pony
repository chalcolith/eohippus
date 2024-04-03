use json = "../json"

class val LiteralFloat is NodeDataWithValue[LiteralFloat, F64]
  let _value: F64

  new val create(value': F64) =>
    _value = value'

  fun name(): String => "LiteralFloat"

  fun val clone(updates: ChildUpdateMap): LiteralFloat =>
    this

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("value", _value))

  fun value(): F64 => _value
