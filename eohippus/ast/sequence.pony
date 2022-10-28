class val Sequence is (Node & NodeWithChildren)
  let _src_info: SrcInfo
  let _children: NodeSeq

  new val create(src_info': SrcInfo, children': NodeSeq) =>
    _src_info = src_info'
    _children = children'

  fun src_info(): SrcInfo => _src_info
  fun get_string(indent: String): String =>
    recover val
      let str: String ref = String
      let inner: String = indent + "  "
      str.append(indent + "<SEQUENCE>\n")
      for child in _children.values() do
        str.append(child.get_string(inner))
        str.append("\n")
      end
      str.append(indent + "</SEQUENCE>")
      str
    end
  fun children(): NodeSeq => _children
