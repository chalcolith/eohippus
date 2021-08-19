use "kiuatan"
use "../parser"
use "../types"

class val AstLiteralBool[CH: ((U8 | U16) & UnsignedInteger[CH])]
  is AstNode[CH]

  let _src_info: SrcInfo[CH]
  let _type: AstType[CH]
  let _value: Bool

  new val create(context: ParserContext[CH], src_info': SrcInfo[CH],
    value': Bool)
  =>
    _src_info = src_info'
    _type = context.builtin().bool()
    _value = value'

  fun src_info(): SrcInfo[CH] => _src_info

  fun ast_type(): AstType[CH] => _type

  fun string(): String iso^ =>
    "<LIT: " + ast_type().string() + " =" + _value.string() + ">"
