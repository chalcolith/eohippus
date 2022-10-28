
class val Jump is (Node & NodeWithChildren)
  let _src_info: SrcInfo
  let _children: NodeSeq

  let _keyword: Keyword

  new val create(src_info': SrcInfo, children': NodeSeq, keyword': Keyword) =>
    _src_info = src_info'
    _children = children'
    _keyword = keyword'

  fun src_info(): SrcInfo => _src_info
  fun get_string(indent: String): String =>
    recover val
      let str: String ref = String
      let inner: String = indent + "  "
      str.append(indent + "<JUMP>\n")
      str.append(_keyword.get_string(inner))
      str.append("\n")
      str.append(indent + "</JUMP>")
      str
    end
  fun children(): NodeSeq => _children

  fun keyword(): Keyword => _keyword
