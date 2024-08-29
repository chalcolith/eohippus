use json = "../json"

primitive StringLiteral
primitive StringTripleQuote

type StringLiteralKind is (StringLiteral | StringTripleQuote)

class val LiteralString is NodeDataWithValue[LiteralString, String]
  let _value: String
  let kind: StringLiteralKind

  new val create(value': String, kind': StringLiteralKind) =>
    _value = value'
    kind = kind'

  fun name(): String => "LiteralString"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    this

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    let kind_str =
      match kind
      | StringLiteral => "StringLiteral"
      | StringTripleQuote => "StringTripleQuote"
      end
    props.push(("kind", kind_str))
    props.push(("value", _value))

  fun value(): String => _value

primitive ParseLiteralString
  fun apply(obj: json.Object, children: NodeSeq): (LiteralString | String) =>
    let value =
      match try obj("value")? end
      | let str: String box =>
        str
      else
        return "LiteralString.value must be a string"
      end
    let kind =
      match try obj("kind")? end
      | "StringLiteral" =>
        StringLiteral
      | "StringTripleQuote" =>
        StringTripleQuote
      else
        return "LiteralString.kind must be a string"
      end
    LiteralString(value.clone(), kind)
