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

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    let kind_str =
      match kind
      | DecimalInteger => "DecimalInteger"
      | HexadecimalInteger => "HexadecimalInteger"
      | BinaryInteger => "BinaryInteger"
      end
    props.push(("kind", kind_str))
    props.push(("value", I128.from[U128](_value)))

  fun value(): U128 => _value

primitive ParseLiteralInteger
  fun apply(obj: json.Object, children: NodeSeq): (LiteralInteger | String) =>
    let value =
      match try obj("value")? end
      | let n: I128 =>
        U128.from[I128](n)
      else
        return "LiteralInteger.value must be an integer"
      end
    let kind =
      match try obj("kind")? end
      | "DecimalInteger" =>
        DecimalInteger
      | "HexadecimalInteger" =>
        HexadecimalInteger
      | "BinaryInteger" =>
        BinaryInteger
      else
        return "LiteralInteger.kind must be a string"
      end
    LiteralInteger(value, kind)
