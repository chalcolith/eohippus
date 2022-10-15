use ".."

class val Docstring is (Node & NodeWithChildren & NodeWithValue[String])
  let _src_info: SrcInfo
  let _children: NodeSeq
  let _value: LiteralString

  new val create(src_info': SrcInfo, children': NodeSeq,
    value': LiteralString)
  =>
    _src_info = src_info'
    _children = children'
    _value = value'

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => value_error()
  fun get_string(indent: String): String =>
    indent + "<DOCSTRING string=\"" + StringUtil.escape(_value.string())
    + "\"/>"
  fun children(): NodeSeq => _children
  fun value(): String => _value.value()
  fun value_error(): Bool => _value.value_error()
