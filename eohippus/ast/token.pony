use ".."

primitive Tokens
  fun single_quote(): String => "'"
  fun double_quote(): String => "\""
  fun triple_double_quote(): String => "\"\"\""
  fun equals(): String => "="
  fun semicolon(): String => ";"
  fun backslash(): String => "\\"
  fun underscore(): String => "_"
  fun comma(): String => ","
  fun minus(): String => "-"
  fun minus_tilde(): String => "-~"
  fun decimal_point(): String => "."

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
  fun get_string(indent: String): String =>
    indent + "<TK string=\"" + StringUtil.escape(_name) + "\"/>"
  fun body(): Span => _body
  fun post_trivia(): Trivia => _post_trivia

  fun name(): String => _name
