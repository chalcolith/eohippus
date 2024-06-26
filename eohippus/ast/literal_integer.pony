use json = "../json"

primitive DecimalInteger
primitive HexadecimalInteger
primitive BinaryInteger
type LiteralIntegerKind is (DecimalInteger | HexadecimalInteger | BinaryInteger)

class val LiteralInteger is NodeDataWithValue[LiteralInteger, U128]
  let _value: U128
  let kind: LiteralIntegerKind

  new val create(value': U128, kind': LiteralIntegerKind) =>
    _value = value'
    kind = kind'

  fun name(): String => "LiteralInteger"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    this

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    let kind_str =
      match kind
      | DecimalInteger => "DecimalInteger"
      | HexadecimalInteger => "HexadecimalInteger"
      | BinaryInteger => "BinaryInteger"
      end
    props.push(("kind", kind_str))
    props.push(("value", I128.from[U128](_value)))

  fun value(): U128 => _value
