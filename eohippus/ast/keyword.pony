use ".."

primitive Keywords
  fun kwd_addressof(): String => "addressof"
  fun kwd_as(): String => "as"
  fun kwd_break(): String => "break"
  fun kwd_compile_error(): String => "compile_error"
  fun kwd_compile_intrinsic(): String => "compile_intrinsic"
  fun kwd_continue(): String => "continue"
  fun kwd_digestof(): String => "digestof"
  fun kwd_error(): String => "error"
  fun kwd_false(): String => "false"
  fun kwd_if(): String => "if"
  fun kwd_loc(): String => "__loc"
  fun kwd_not(): String => "not"
  fun kwd_primitive(): String => "primitive"
  fun kwd_return(): String => "return"
  fun kwd_this(): String => "this"
  fun kwd_true(): String => "true"
  fun kwd_use(): String => "use"

class val Keyword is (Node & NodeWithTrivia & NodeWithName)
  let _src_info: SrcInfo
  let _body: Span
  let _post_trivia: Trivia
  let _name: String

  new val create(src_info': SrcInfo, post_trivia': Trivia, name': String) =>
    _src_info = src_info'
    _body = Span(SrcInfo(src_info'.locator(), src_info'.start(),
      post_trivia'.src_info().start()))
    _post_trivia = post_trivia'
    _name = name'

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => false
  fun get_string(indent: String): String =>
    indent + "<KWD name=\"" + StringUtil.escape(_name) + "\"/>"
  fun body(): Span => _body
  fun post_trivia(): Trivia => _post_trivia

  fun name(): String => _name
