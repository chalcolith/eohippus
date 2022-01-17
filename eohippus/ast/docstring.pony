class val Docstring is (Node & NodeValued[String] & NodeParent & NodeTrivia)
  let _src_info: SrcInfo
  let _children: NodeSeq[Node]
  let _trivia: Trivia
  let _string: LiteralString

  new val create(src_info': SrcInfo, children': NodeSeq[Node],
    trivia': Trivia, string': LiteralString)
  =>
    _src_info = src_info'
    _children = children'
    _trivia = trivia'
    _string = string'

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => value_error()
  fun string(): String iso^ => "<DOCSTRING>" + _string.string() + "</DOCSTRING>"
  fun value(): String => _string.value()
  fun value_error(): Bool => _string.value_error()
  fun children(): NodeSeq[Node] => _children
  fun trivia(): Trivia => _trivia
