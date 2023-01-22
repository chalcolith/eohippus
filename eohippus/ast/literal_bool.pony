use json = "../json"
use parser = "../parser"
use types = "../types"

class val LiteralBool is
  (Node & NodeWithType[LiteralBool] & NodeWithTrivia & NodeWithValue[Bool])
  let _src_info: SrcInfo
  let _ast_type: types.AstType
  let _body: Span
  let _post_trivia: Trivia
  let _value: Bool

  new val create(context: parser.Context, src_info': SrcInfo,
    post_trivia': Trivia, value': Bool)
  =>
    _src_info = src_info'
    _ast_type = context.builtin().bool_type()
    _body = Span(SrcInfo(src_info'.locator(), src_info'.start(),
      post_trivia'.src_info().start()))
    _post_trivia = post_trivia'
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

  fun info(): json.Item val =>
    recover
      json.Object([
        ("node", "LiteralBool")
        ("type", ast_type().string())
        ("value", _value.string())
      ])
    end

  fun ast_type(): types.AstType => _ast_type

  fun val with_ast_type(ast_type': types.AstType): LiteralBool => this

  fun body(): Span => _body

  fun post_trivia(): Trivia => _post_trivia

  fun value(): Bool => _value

  fun value_error(): Bool => false
