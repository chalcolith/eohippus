use "itertools"

use ast = "../ast"
use json = "../json"
use parser = "../parser"
use types = "../types"

use ".."

class val LiteralString is
  (Node & NodeWithType[LiteralString] & NodeWithValue[String]
    & NodeWithChildren & NodeWithTrivia)

  let _triple_quote: Bool
  let _src_info: SrcInfo
  let _ast_type: types.AstType
  let _children: NodeSeq
  let _body: Span
  let _post_trivia: Trivia
  let _value: String
  let _value_error: Bool

  new val create(context: parser.Context, src_info': SrcInfo,
    children': NodeSeq, post_trivia': Trivia)
  =>
    _src_info = src_info'
    _ast_type = context.builtin().string_type()
    _children = children'
    _body = Span(SrcInfo(src_info'.locator(), src_info'.start(),
      post_trivia'.src_info().start()))
    _post_trivia = post_trivia'
    (_triple_quote, _value, _value_error) = _get_string_value(children')

  new val from(context: parser.Context, triple_quote': Bool,
    src_info': SrcInfo, value': String, value_error': Bool = false)
  =>
    _triple_quote = triple_quote'
    _src_info = src_info'
    _ast_type = context.builtin().string_type()
    _children = recover Array[Node] end
    _body = Span(SrcInfo(src_info'.locator(), src_info'.start(),
      src_info'.next()))
    _post_trivia = Trivia(SrcInfo(src_info'.locator(), src_info'.next(),
      src_info'.next()), [])
    _value = value'
    _value_error = value_error'

  fun is_triple_quote(): Bool => _triple_quote

  fun src_info(): SrcInfo => _src_info

  fun has_error(): Bool => _value_error

  fun eq(other: box->Node): Bool =>
    match other
    | let ls: LiteralString =>
      (this._src_info == ls._src_info)
        and (this._triple_quote == ls._triple_quote)
        and (this._value == ls._value)
        and (this._value_error == ls._value_error)
    else
      false
    end

  fun info(): json.Item iso^ =>
    recover
      let type_name = recover val _ast_type.string() end
      json.Object([
        ("node", "LiteralString")
        ("type", type_name)
        ("triple", _triple_quote)
        ("value", _value)
      ])
    end

  fun ast_type(): (types.AstType | None) => _ast_type
  fun val with_ast_type(ast_type': types.AstType): LiteralString => this
  fun children(): NodeSeq => _children
  fun body(): Span => _body
  fun post_trivia(): Trivia => _post_trivia
  fun value(): String => _value
  fun value_error(): Bool => _value_error

  fun tag _get_string_value(children': NodeSeq)
    : (Bool, String, Bool)
  =>
    var triple = false
    let indented =
      recover val
        let indented' = String
        var first_token = true
        for child in children'.values() do
          match child
          | let tok: ast.Token =>
            if tok.name() =="\"\"\"" then
              triple = true
            end
            if first_token then
              let ptsi = tok.post_trivia().src_info()
              indented'.concat(ptsi.start().values(ptsi.next()))
              first_token = false
            end
          | let span: ast.Span =>
            let spsi = span.src_info()
            indented'.concat(spsi.start().values(spsi.next()))
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
      let lines = _get_lines(indented.array())
      if lines.size() > 1 then
        try
          (var start, var next) = lines(0)?
          let first_line = indented.trim(start, next - 1)
          let fli = Iter[U8](first_line.values())
          // if the first line is all whitespace, then ignore it,
          // and trim prefixes from from subseqent lines
          if fli.all({(ch) => (ch == ' ') or (ch == '\t') }) then
            (start, next) = lines(1)?
            let indent =
              recover val
                let second_line = indented.trim(start, next - 1)
                let sli = Iter[U8](second_line.values())
                String.>concat(sli.take_while(
                  {(ch) => (ch == ' ') or (ch == '\t') }))
              end
            let isz = indent.size()

            let trimmed =
              recover val
                let trimmed' = String
                var i: USize = 1
                while i < lines.size() do
                  if i > 1 then trimmed'.append("\n") end
                  (let s, let n) = lines(i)?
                  if indented.compare_sub(indent, isz, ISize.from[USize](s))
                    is Equal
                  then
                    trimmed'.append(indented.trim(s + isz, n - 1))
                  else
                    trimmed'.append(indented.trim(s, n - 1))
                  end
                  i = i + 1
                end
                trimmed'
              end
            return (triple, trimmed, false)
          end
        end
      end
    end
    (triple, indented, false)

fun tag _get_lines(str: Array[U8] val): Array[(USize, USize)] val =>
  recover
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
  end
