use ".."

class val Span is Node
  let _src_info: SrcInfo

  new val create(src_info': SrcInfo) =>
    _src_info = src_info'

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => false
  fun get_string(indent: String): String =>
    let str = _src_info.literal_source()
    indent + "<SPAN string=\"" + StringUtil.escape(str) + "\"/>"

  fun literal_source(): String => _src_info.literal_source()
