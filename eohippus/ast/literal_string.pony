use parser = "../parser"
use types = "../types"

use ".."

class val LiteralString is
  (Node & NodeTypes[LiteralString] & NodeValued[String] & NodeParent)

  let _triple_quote: Bool
  let _src_info: SrcInfo
  let _ast_type: types.AstType
  let _value: String
  let _value_error: Bool
  let _children: ReadSeq[Node] val

  new val create(context: parser.Context, src_info': SrcInfo,
    children': ReadSeq[Node] val)
  =>
    _src_info = src_info'
    _ast_type = context.builtin().string_type()
    (_triple_quote, _value, _value_error) = _get_string_value(children')
    _children = children'

  new val from(context: parser.Context, src_info': SrcInfo, value': String,
    value_error': Bool = false)
  =>
    _src_info = src_info'
    _ast_type = context.builtin().string_type()
    _value = value'
    _value_error = value_error'
    _children = recover Array[Node] end

  fun triple_quote(): Bool => _triple_quote

  fun src_info(): SrcInfo => _src_info
  fun eq(other: box->Node): Bool =>
    match other
    | let ls: LiteralStringRegular =>
      (this._src_info == lc._src_info) and (this._value == lc._value)
        and (this._value_error == lc._value_error)
    else
      false
    end
  fun string(): String iso^ =>
    "<LIT: builtin/String = \"" + StringUtil.escape(_value) + "\">"

  fun ast_type(): (types.AstType | None) => _ast_type
  fun val with_ast_type(ast_type': types.AstType): LiteralStringRegular => this

  fun value(): String => _value
  fun value_error(): Bool => _value_error

  fun children(): ReadSeq[Node] val => _children

  fun tag _get_string_value(children': ReadSeq[Node] val)
    : (Bool, String, Bool)
  =>
    recover
      var triple = false
      let indented = String
      for child in children.values() do
        match child
        | let tdq: ast.GlyphTripleDoubleQuote =>
          triple = true
        | let dq: ast.GlyphDoubleQuote =>
          None
        | let span: ast.Span =>
          for ch in span.src_info().start().values(span.src_info().next())
            indented.push(ch)
          end
        | let lce: LiteralCharEscape =>
          result.push_utf32(lce.value())
        | let lcu: LiteralCharUnicode =>
          result.push_utf32(lcu.value())
        end
      end

      if triple then
        // find first line break
        try
          let size = indented.size()
          var in_initial_ws = false

        end
      end
      (triple, indented, false)
    end
