use json = "../json"

primitive Tokens
  fun amp(): String => "&"
  fun arrow(): String => "->"
  fun at(): String => "@"
  fun backslash(): String => "\\"
  fun bang(): String => "!"
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
  fun equals(): String => "="
  fun hash(): String => "#"
  fun hat(): String => "^"
  fun minus(): String => "-"
  fun minus_tilde(): String => "-~"
  fun open_curly(): String => "{"
  fun open_paren(): String => "("
  fun open_square(): String => "["
  fun ques(): String => "?"
  fun semicolon(): String => ";"
  fun single_quote(): String => "'"
  fun subtype(): String => "<:"
  fun tilde(): String => "~"
  fun triple_double_quote(): String => "\"\"\""
  fun underscore(): String => "_"

class val Token is NodeData
  let string: String

  new create(string': String) =>
    string = string'

  fun name(): String => "Token"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("string", string))
