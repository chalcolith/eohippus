use "itertools"

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

  new val from(context: parser.Context, triple_quote': Bool,
    src_info': SrcInfo, value': String, value_error': Bool = false)
  =>
    _triple_quote = triple_quote'
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
      (this._src_info == lc._src_info)
        and (this._triple_quote == lc._triple_quote)
        and (this._value == lc._value)
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
    var triple = false
    let indented =
      recover val
        let indented' = String
        for child in children.values() do
          match child
          | let tdq: ast.GlyphTripleDoubleQuote =>
            triple = true
          | let dq: ast.GlyphDoubleQuote =>
            None
          | let span: ast.Span =>
            for ch in span.src_info().start().values(span.src_info().next())
              indented'.push(ch)
            end
          | let lce: LiteralCharEscape =>
            indented'.push_utf32(lce.value())
          | let lcu: LiteralCharUnicode =>
            indented'.push_utf32(lcu.value())
          end
        end
        indented'
      end

    if triple and (indented.size() > 0) then
      // get pairs of (start, next) for each line in the string
      let lines = _get_lines(indented.array)
      if lines.size() > 1 then
        try
          (var start, var next) = lines(0)?
          let first_line = Iter[U8](indented.trim(start, next).values())
          // if the first line is all whitespace, then ignore it,
          // and trim prefixes from from subseqent lines
          if first_line.all({(ch) => (ch == ' ') or (ch == '\t') }) then
            (start, next) = lines(1)?
            let second_line = Iter[U8](indented.trim(start, next).values())
            let indent = String.concat(second_line.take_while(
              {(ch) => (ch == ' ') or (ch == '\t') })
            let isz = indent.size()

            let trimmed =
              recover val
                let trimmed' = String
                for (s, n) in Iter[(USize, USize)](lines.values()).skip(1) do
                  if indented.compare_sub(indent, isz, s) is Equal then
                    trimmed'.append(indented.trim(s + isz, n))
                  else
                    trimmed'.append(indented.trim(s, n))
                  end
                end
              end
            (triple, trimmed, false)
          end
        end
      end
    end
    (triple, indented, false)

fun tag _get_lines(str: Array[U8] val): Array[(USize, USize)] ref =>
  var start_pos: USize = 0
  var next_pos: USize = 0

  let result = Array[(USize, USize)]
  let size = str.size()
  var cur: USize = 0
  try
    while cur < size do
      let ch = str(cur)?
      if ch == '\n' then
        if ((cur+1) < size) and (str(cur+1)? == '\r') then
          next_pos = cur + 2
        else
          next_pos = cur + 1
        end
      elseif ch == '\r' then
        if ((cur+1) < size) and (str(cur+1)? == '\n') then
          next_pos = cur + 2
        else
          next_pos = cur + 1
        end
      else
        cur = cur + 1
        continue
      end
      result.push((start_pos, next_pos))
      start_pos = next_pos
      cur = next_pos
    end
    if start_pos < cur then
      result.push((start_pos, cur))
    end
  end
  result
