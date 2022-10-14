use ".."

primitive Tokens
  fun single_quote(): String => "'"
  fun double_quote(): String => "\""
  fun triple_double_quote(): String => "\"\"\""
  fun equals(): String => "="
  fun semicolon(): String => ";"
  fun backslash(): String => "\\"
  fun underscore(): String => "_"
  fun comma(): String => ","

class val Token is Node
  let _src_info: SrcInfo
  let _str: String

  new val create(src_info': SrcInfo) =>
    _src_info = src_info'
    _str = _src_info.literal_source()

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => false
  fun get_string(indent: String): String =>
    indent + "<TK string=\"" + StringUtil.escape(_str) + "\"/>"

  fun str(): String => _str
