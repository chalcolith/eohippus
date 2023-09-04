use json = "../json"

type Literal is
  ( LiteralBool
  | LiteralChar
  | LiteralFloat
  | LiteralInteger
  | LiteralString )

class val LiteralBool is NodeDataWithValue[Bool]
  let _value: Bool

  new val create(value': Bool) =>
    _value = value'

  fun name(): String => "LiteralBool"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("value", _value))

  fun value(): Bool => _value
