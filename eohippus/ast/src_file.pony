use parser = "../parser"

class val SrcFile is
  (Node & NodeWithChildren & NodeWithTrivia & NodeWithDocstring)
  let _src_info: SrcInfo
  let _children: NodeSeq
  let _body: Span
  let _pre_trivia: Trivia
  let _post_trivia: Trivia
  let _docstring: NodeSeq[Docstring]

  let _usings: NodeSeq
  let _typedefs: NodeSeq

  new val create(src_info': SrcInfo, children': NodeSeq,
    pre_trivia': Trivia, docstring': NodeSeq[Docstring],
    usings': NodeSeq, typedefs': NodeSeq)
  =>
    _src_info = src_info'
    _children = children'
    _body = Span(SrcInfo(src_info'.locator(), pre_trivia'.src_info().next(),
      src_info'.next()))
    _pre_trivia = pre_trivia'
    _post_trivia = Trivia(
      SrcInfo(src_info'.locator(), src_info'.next(), src_info'.next()), [])
    _docstring = docstring'
    _usings = usings'
    _typedefs = typedefs'

  fun src_info(): SrcInfo => _src_info
  fun get_string(indent: String): String =>
    recover val
      let str: String ref = String
      str.append(indent + "<SRC_FILE locator=\"" + _src_info.locator() +
        "\">\n")
      let inner: String = indent + "  "
      for ds in _docstring.values() do
        str.append(ds.get_string(inner))
        str.append("\n")
      end
      for us in _usings.values() do
        str.append(us.get_string(inner))
        str.append("\n")
      end
      for td in _typedefs.values() do
        str.append(td.get_string(inner))
        str.append("\n")
      end
      str.append(indent + "</SRC_FILE>")
      str
    end

  fun children(): NodeSeq => _children
  fun body(): Span => _body
  fun pre_trivia(): Trivia => _pre_trivia
  fun post_trivia(): Trivia => _post_trivia
  fun docstring(): NodeSeq[Docstring] => _docstring

  fun usings(): NodeSeq => _usings
  fun typedefs(): NodeSeq => _typedefs
