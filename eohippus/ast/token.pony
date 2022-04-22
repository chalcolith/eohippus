use ".."

class val Token is Node
  let _src_info: SrcInfo
  let _str: String

  new val create(src_info': SrcInfo, str': String) =>
    _src_info = src_info'
    _str = str'

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => false
  fun get_string(indent: String): String =>
    indent + "<TOKEN: \"" + StringUtil.escape(_str) + "\">"

  fun str(): String => _str
