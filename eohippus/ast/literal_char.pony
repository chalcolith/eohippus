use json = "../json"

primitive CharLiteral
primitive CharEscaped
primitive CharUnicode

type CharLiteralKind is (CharLiteral | CharEscaped | CharUnicode)

class val LiteralChar is NodeDataWithValue[LiteralChar, U32]
  """
    A character literal.
    - `kind`: either a single character 'x' or a standard escaped character, or
      a Unicode escaped character.
  """

  let _value: U32
  let kind: CharLiteralKind

  new val create(kind': CharLiteralKind, value': U32) =>
    _value = value'
    kind = kind'

  fun name(): String => "LiteralChar"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    this

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
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

primitive ParseLiteralChar
  fun apply(obj: json.Object, children: NodeSeq): (LiteralChar | String) =>
    let kind =
      match try obj("kind")? end
      | let str: String box =>
        match str
        | "CharLiteral" =>
          CharLiteral
        | "CharEscaped" =>
          CharEscaped
        | "CharUnicode" =>
          CharUnicode
        else
          return "LiteralChar.kind must be " +
            "(CharLiteral | CharEscaped | CharUnicode)"
        end
      else
        return "LiteralChar.kind must be a string"
      end
    let value =
      match try obj("value")? end
      | let str: String box =>
        match try str.utf32(0)? end
        | (let int: U32, let _: U8) =>
          int
        else
          return "LiteralChar.value must be a valid Unicode character"
        end
      else
        return "LiteralChar.value must be a valid Unicode character"
      end
    LiteralChar(kind, value)
