use ".."

class val Docstring is (Node & NodeValued[String] & NodeParent & NodeTrivia)
  let _src_info: SrcInfo
  let _children: NodeSeq
  let _pre_trivia: Trivia
  let _post_trivia: Trivia
  let _string: LiteralString

  new val create(src_info': SrcInfo, children': NodeSeq,
    pre_trivia': Trivia, post_trivia': Trivia, string': LiteralString)
  =>
    _src_info = src_info'
    _children = children'
    _pre_trivia = pre_trivia'
    _post_trivia = post_trivia'
    _string = string'

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => value_error()
  fun get_string(indent: String): String =>
    indent + "<DOCSTRING>" + StringUtil.escape(_string.string())
    + "</DOCSTRING>"
  fun value(): String => _string.value()
  fun value_error(): Bool => _string.value_error()
  fun children(): NodeSeq => _children
  fun pre_trivia(): Trivia => _pre_trivia
  fun post_trivia(): Trivia => _post_trivia
