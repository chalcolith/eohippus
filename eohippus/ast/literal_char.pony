use json = "../json"

primitive CharLiteral
primitive CharEscaped
primitive CharUnicode

type CharLiteralKind is (CharLiteral | CharEscaped | CharUnicode)

class val LiteralChar is NodeDataWithValue[U32]
  """
    A character literal.
    - `kind`: either a single character 'x' or a standard escaped character, or
      a Unicode escaped character.
  """

  let _value: U32
  let kind: CharLiteralKind

  new val create(value': U32, kind': CharLiteralKind) =>
    _value = value'
    kind = kind'

  fun name(): String => "LiteralChar"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData =>
    this

  fun add_json_props(props: Array[(String, json.Item)]) =>
    let kind_str =
      match kind
      | CharLiteral => "CharLiteral"
      | CharEscaped => "CharEscaped"
      | CharUnicode => "CharUnicode"
      end
    props.push(("kind", kind_str))
    let str = recover val String .> push_utf32(_value) end
    props.push(("value", str))

  fun value(): U32 => _value
