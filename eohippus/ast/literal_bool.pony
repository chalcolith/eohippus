use parser = "../parser"
use types = "../types"

class val LiteralBool is (Node & NodeTyped[LiteralBool] & NodeValued[Bool])
  let _src_info: SrcInfo
  let _ast_type: types.AstType
  let _value: Bool

  new val create(context: parser.Context, src_info': SrcInfo, value': Bool) =>
    _src_info = src_info'
    _ast_type = context.builtin().bool_type()
    _value = value'

  fun src_info(): SrcInfo => _src_info
  fun eq(other: box->Node): Bool =>
    match other
    | let lb: box->LiteralBool =>
      (this._src_info == lb._src_info) and (this._value == lb._value)
    else
      false
    end
  fun ne(other: box->Node): Bool => not this.eq(other)
  fun string(): String iso^ =>
    "<LIT: " + ast_type().string() + " = " + _value.string() + ">"

  fun ast_type(): types.AstType => _ast_type
  fun val with_ast_type(ast_type': types.AstType): LiteralBool => this

  fun value(): Bool => _value
  fun value_error(): Bool => false
