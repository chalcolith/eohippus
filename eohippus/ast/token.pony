use json = "../json"
use ".."

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
  fun comma(): String => ","
  fun decimal_point(): String => "."
  fun dot(): String => "."
  fun double_quote(): String => "\""
  fun equals(): String => "="
  fun hash(): String => "#"
  fun hat(): String => "^"
  fun minus_tilde(): String => "-~"
  fun minus(): String => "-"
  fun open_curly(): String => "{"
  fun open_paren(): String => "("
  fun open_square(): String => "["
  fun semicolon(): String => ";"
  fun single_quote(): String => "'"
  fun subtype(): String => "<:"
  fun tilde(): String => "~"
  fun triple_double_quote(): String => "\"\"\""
  fun underscore(): String => "_"

class val Token is (Node & NodeWithTrivia & NodeWithName)
  let _src_info: SrcInfo
  let _body: Span
  let _post_trivia: Trivia
  let _name: String

  new val create(src_info': SrcInfo, post_trivia': Trivia) =>
    _src_info = src_info'
    _body = Span(SrcInfo(src_info'.locator(), src_info'.start(),
      post_trivia'.src_info().start()))
    _post_trivia = post_trivia'
    _name = _body.literal_source()

  fun src_info(): SrcInfo => _src_info

  fun has_error(): Bool => false

  fun info(): json.Item val =>
    recover
      json.Object([
        ("node", "Token")
        ("string", _name)
      ])
    end

  fun body(): Span => _body

  fun post_trivia(): Trivia => _post_trivia

  fun name(): String => _name
