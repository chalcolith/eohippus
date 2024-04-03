use json = "../json"

type Literal is
  ( LiteralBool
  | LiteralChar
  | LiteralFloat
  | LiteralInteger
  | LiteralString )

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
