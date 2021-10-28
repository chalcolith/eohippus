
class val GlyphDoubleQuote is (Node & NodeValued[String])
  let _src_info: SrcInfo
  let _value: String
  let _value_error: Bool

  new val create(src_info': SrcInfo) =>
    _src_info = src_info'
    _value = "\""
    _value_error = false

  fun src_info(): SrcInfo => _src_info
  fun string(): String iso^ =>
    "<GLYPH: DOUBLE_QUOTE>"

class val GlyphTripleDoubleQuote is (Node & NodeValued[String])
  let _src_info: SrcInfo
  let _value: String
  let _value_error: Bool

  new val create(src_info': SrcInfo) =>
    _src_info = src_info'
    _value = "\"\"\""
    _value_error = false

  fun src_info(): SrcInfo => _src_info
  fun string(): String iso^ =>
    "<GLYPH: TRIPLE_DOUBLE_QUOTE>"
