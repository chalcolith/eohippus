use ".."

class val Identifier is Node
  let _src_info: SrcInfo
  let _name: String

  new val create(src_info': SrcInfo) =>
    _src_info = src_info'
    _name = _src_info.literal_source()

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => false
  fun name(): String => _name
  fun string(): String iso^ =>
    "<ID: \"" + StringUtil.escape(name()) + "\">"
