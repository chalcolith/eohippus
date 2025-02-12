use json = "../json"

primitive Tokens
  """The source of truth for non-alphabetic source tokens."""
  fun amp(): String => "&"
  fun arrow(): String => "->"
  fun at(): String => "@"
  fun backslash(): String => "\\"
  fun bang(): String => "!"
  fun bang_equal(): String => "!="
  fun bang_equal_tilde(): String => "!=~"
  fun bar(): String => "|"
  fun chain(): String => ".>"
  fun close_curly(): String => "}"
  fun close_paren(): String => ")"
  fun close_square(): String => "]"
  fun colon(): String => ":"
  fun comma(): String => ","
  fun decimal_point(): String => "."
  fun dot(): String => "."
  fun double_quote(): String => "\""
  fun ellipsis(): String => "..."
  fun equals(): String => "="
  fun equal_arrow(): String => "=>"
  fun equal_equal(): String => "=="
  fun equal_equal_tilde(): String => "==~"
  fun greater(): String => ">"
  fun greater_equal(): String => ">="
  fun greater_equal_tilde(): String => ">=~"
  fun greater_tilde(): String => ">~"
  fun hash(): String => "#"
  fun hat(): String => "^"
  fun less(): String => "<"
  fun less_equal(): String => "<="
  fun less_equal_tilde(): String => "<=~"
  fun less_tilde(): String => "<~"
  fun minus(): String => "-"
  fun minus_tilde(): String => "-~"
  fun open_curly(): String => "{"
  fun open_paren(): String => "("
  fun open_square(): String => "["
  fun percent(): String => "%"
  fun percent_percent(): String => "%%"
  fun percent_percent_tilde(): String => "%%~"
  fun percent_tilde(): String => "%~"
  fun plus(): String => "+"
  fun plus_tilde(): String => "+~"
  fun ques(): String => "?"
  fun semicolon(): String => ";"
  fun shift_left(): String => "<<"
  fun shift_left_tilde(): String => "<<~"
  fun shift_right(): String => ">>"
  fun shift_right_tilde(): String => ">>~"
  fun single_quote(): String => "'"
  fun slash(): String => "/"
  fun slash_tilde(): String => "/~"
  fun star(): String => "*"
  fun star_tilde(): String => "*~"
  fun subtype(): String => "<:"
  fun tilde(): String => "~"
  fun triple_double_quote(): String => "\"\"\""
  fun underscore(): String => "_"

class val Token is NodeData
  let string: String

  new val create(string': String) =>
    string = string'

  fun name(): String => "Token"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    this

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    props.push(("string", string))

primitive ParseToken
  fun apply(obj: json.Object val, children: NodeSeq): (Token | String) =>
    let string =
      match try obj("string")? end
      | let s: String box =>
        s
      else
        return "Token.string must be a string"
      end
    Token(string.clone())
