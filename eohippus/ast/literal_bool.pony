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

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData =>
    this

  fun add_json_props(
    props: Array[(String, json.Item)],
    lines_and_columns: (LineColumnMap | None) = None)
  =>
    props.push(("value", _value))

  fun value(): Bool => _value
