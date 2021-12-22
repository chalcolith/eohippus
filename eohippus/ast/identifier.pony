use ".."

class val Identifier is Node
  let _src_info: SrcInfo

  new val create(src_info': SrcInfo) =>
    _src_info = src_info'

  fun src_info(): SrcInfo => _src_info

  fun name(): String =>
    _src_info.literal_source()

  fun string(): String iso^ =>
    "<ID: \"" + StringUtil.escape(name()) + "\">"
