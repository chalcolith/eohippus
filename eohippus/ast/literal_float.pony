use json = "../json"

class val LiteralFloat is NodeDataWithValue[F64]
  let _value: F64

  new val create(value': F64) =>
    _value = value'

  fun name(): String => "LiteralFloat"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData =>
    this

  fun add_json_props(
    props: Array[(String, json.Item)],
    lines_and_columns: (LineColumnMap | None) = None)
  =>
    props.push(("value", _value))

  fun value(): F64 => _value
