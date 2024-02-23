use json = "../json"

primitive StringLiteral
primitive StringTripleQuote

type StringLiteralKind is (StringLiteral | StringTripleQuote)

class val LiteralString is NodeDataWithValue[String]
  let _value: String
  let kind: StringLiteralKind

  new val create(value': String, kind': StringLiteralKind) =>
    _value = value'
    kind = kind'

  fun name(): String => "LiteralString"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData =>
    this

  fun add_json_props(
    props: Array[(String, json.Item)],
    lines_and_columns: (LineColumnMap | None) = None)
  =>
    let kind_str =
      match kind
      | StringLiteral => "StringLiteral"
      | StringTripleQuote => "StringTripleQuote"
      end
    props.push(("kind", kind_str))
    props.push(("value", _value))

  fun value(): String => _value
