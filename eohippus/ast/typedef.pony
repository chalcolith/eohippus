use parser = "../parser"

class val TypedefPrimitive is (Node & NodeTrivia & NodeDocstring)
  let _src_info: SrcInfo
  let _pre_trivia: Trivia
  let _post_trivia: Trivia
  let _docstring: NodeSeq[Docstring]
  let _identifier: Identifier

  new val create(src_info': SrcInfo, pre_trivia': Trivia, post_trivia': Trivia,
    docstring': NodeSeq[Docstring], identifier': Identifier)
  =>
    _src_info = src_info'
    _pre_trivia = pre_trivia'
    _post_trivia = post_trivia'
    _docstring = docstring'
    _identifier = identifier'

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => false
  fun get_string(indent: String): String =>
    indent + "<PRIMITIVE name=\"" + _identifier.name() + "\"/>"
  fun pre_trivia(): Trivia => _pre_trivia
  fun post_trivia(): Trivia => _post_trivia
  fun docstring(): NodeSeq[Docstring] => _docstring

  fun identifier(): Identifier => _identifier
