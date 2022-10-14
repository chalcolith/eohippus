use ".."

primitive Keywords
  fun kwd_true(): String => "true"
  fun kwd_false(): String => "false"
  fun kwd_use(): String => "use"
  fun kwd_if(): String => "if"
  fun kwd_not(): String => "not"
  fun kwd_primitive(): String => "primitive"
  fun kwd_loc(): String => "__loc"
  fun kwd_this(): String => "this"

class val Keyword is Node
  let _src_info: SrcInfo
  let _name: String

  new val create(src_info': SrcInfo) =>
    _src_info = src_info'
    _name = _src_info.literal_source()

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => false
  fun get_string(indent: String): String =>
    indent + "<KWD name=\"" + StringUtil.escape(_name) + "\"/>"

  fun name(): String => _name
