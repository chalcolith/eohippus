use json = "../json"

primitive CharLiteral
primitive CharEscaped
primitive CharUnicode

type CharLiteralKind is (CharLiteral | CharEscaped | CharUnicode)

class val LiteralChar is NodeDataWithValue[U32]
  let _value: U32
  let kind: CharLiteralKind

  new val create(value': U32, kind': CharLiteralKind) =>
    _value = value'
    kind = kind'

  fun name(): String => "LiteralChar"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    let kind_str =
      match kind
      | CharLiteral => "CharLiteral"
      | CharEscaped => "CharEscaped"
      | CharUnicode => "CharUnicode"
      end
    props.push(("kind", kind_str))
    props.push(("value", _value.string()))

  fun value(): U32 => _value

// class val LiteralChar is
//   (Node & NodeWithType[LiteralChar] & NodeWithChildren & NodeWithTrivia
//     & NodeWithValue[U32])

//   let _src_info: SrcInfo
//   let _ast_type: (types.AstType | None)
//   let _children: NodeSeq
//   let _body: Span
//   let _post_trivia: Trivia
//   let _value: U32
//   let _value_error: Bool

//   new val create(src_info': SrcInfo, children': NodeSeq,
//     post_trivia': Trivia)
//   =>
//     _src_info = src_info'
//     _ast_type = None
//     _children = children'
//     _body = Span(SrcInfo(src_info'.locator(), src_info'.start(),
//       post_trivia'.src_info().start()))
//     _post_trivia = post_trivia'
//     (_value, _value_error) = _get_char_value(children')

//   new val from(src_info': SrcInfo, value': U32, value_error': Bool = false) =>
//     _src_info = src_info'
//     _ast_type = None
//     _children = recover Array[Node] end
//     _body = Span(src_info')
//     _post_trivia = Trivia(SrcInfo(src_info'.locator(), src_info'.next(),
//       src_info'.next()), [])
//     _value = value'
//     _value_error = value_error'

//   new val _with_ast_type(orig: LiteralChar, ast_type': types.AstType) =>
//     _src_info = orig._src_info
//     _ast_type = ast_type'
//     _children = orig._children
//     _body = orig._body
//     _post_trivia = orig._post_trivia
//     _value = orig._value
//     _value_error = orig._value_error

//   fun src_info(): SrcInfo => _src_info

//   fun has_error(): Bool => _value_error

//   fun eq(other: box->Node): Bool =>
//     match other
//     | let lc: LiteralChar =>
//       (this._src_info == lc._src_info) and (this._value == lc._value)
//         and (this._value_error == lc._value_error)
//     else
//       false
//     end

//   fun info(): json.Item val =>
//     let type_name =
//       match _ast_type
//       | let type': types.AstType =>
//         type'.string()
//       else
//         "?LiteralChar?"
//       end
//     recover
//       json.Object([
//         ("node", "LiteralChar")
//         ("type", type_name)
//         ("value", if _value_error then "?ERROR?" else _value.string() end)
//       ])
//     end

//   fun ast_type(): (types.AstType | None) => _ast_type

//   fun val with_ast_type(ast_type': types.AstType): LiteralChar =>
//     LiteralChar._with_ast_type(this, ast_type')

//   fun children(): NodeSeq => _children

//   fun body(): Span => _body

//   fun post_trivia(): Trivia => _post_trivia

//   fun value(): U32 => _value

//   fun value_error(): Bool => _value_error

//   fun tag _get_char_value(children': NodeSeq): (U32, Bool) =>
//     var v: U32 = 0
//     for child' in children'.values() do
//       match child'
//       | let lce: LiteralCharEscape =>
//         if lce.value_error() then
//           return (0, true)
//         else
//           v = (v << 8) or lce.value()
//         end
//       | let span: Span =>
//         for ch in span.src_info().start().values(span.src_info().next()) do
//           if (ch and 0b11111000) == 0b11110000 then
//             v = (v << 3) or U32.from[U8](ch and 0b00000111)
//           elseif (ch and 0b11100000) == 0b11100000 then
//             v = (v << 4) or U32.from[U8](ch and 0b00001111)
//           elseif (ch and 0b11100000) == 0b11000000 then
//             v = (v << 5) or U32.from[U8](ch and 0b00011111)
//           elseif (ch and 0b11000000) == 0b10000000 then
//             v = (v << 6) or U32.from[U8](ch and 0b00111111)
//           else
//             v = (v << 8) or U32.from[U8](ch)
//           end
//         end
//       end
//     end
//     (v, false)

// class val LiteralCharEscape is (Node & NodeWithValue[U32])
//   let _src_info: SrcInfo
//   let _value: U32
//   let _value_error: Bool

//   new val create(src_info': SrcInfo) =>
//     _src_info = src_info'
//     (_value, _value_error) = _get_char_value(_src_info)

//   new val from(src_info': SrcInfo, value': U32, value_error': Bool = false) =>
//     _src_info = src_info'
//     _value = value'
//     _value_error = value_error'

//   fun src_info(): SrcInfo => _src_info

//   fun eq(other: box->Node): Bool =>
//     match other
//     | let lc: LiteralCharEscape =>
//       (this._src_info == lc._src_info) and (this._value == lc._value)
//         and (this._value_error == lc._value_error)
//     else
//       false
//     end

//   fun info(): json.Item val =>
//     recover
//       json.Object([
//         ("node", "LiteralCharEscape")
//         ("value", if _value_error then "?ERROR?" else _value.string() end)
//       ])
//     end

//   fun value(): U32 => _value

//   fun value_error(): Bool => _value_error

//   fun tag _get_char_value(si: SrcInfo): (U32, Bool) =>
//     var begin = true
//     var is_slash = false
//     var is_hex = false
//     var v: U32 = 0
//     for ch in si.start().values(si.next()) do
//       if begin then
//         begin = false
//         if ch == '\\' then
//           is_slash = true
//           continue
//         end
//       elseif is_hex then
//         if (ch >= '0') and (ch <= '9') then
//           v = (v * 16) + U32.from[U8](ch - '0')
//         elseif (ch >= 'a') and (ch <= 'f') then
//           v = (v * 16) + U32.from[U8](ch - 'a') + 10
//         elseif (ch >= 'A') and (ch <= 'F') then
//           v = (v * 16) + U32.from[U8](ch - 'A') + 10
//         else
//           return (0, true)
//         end
//       elseif is_slash then
//         if (ch == 'x') or (ch == 'X') then
//           is_hex = true
//           continue
//         elseif ch == 'a' then
//           return ('\a', false)
//         elseif ch == 'b' then
//           return ('\b', false)
//         elseif ch == 'e' then
//           return ('\e', false)
//         elseif ch == 'f' then
//           return ('\f', false)
//         elseif ch == 'n' then
//           return ('\n', false)
//         elseif ch == 'r' then
//           return ('\r', false)
//         elseif ch == '\t' then
//           return ('\t', false)
//         elseif ch == '\v' then
//           return ('\v', false)
//         elseif ch == '\\' then
//           return ('\\', false)
//         elseif ch == '0' then
//           return ('\0', false)
//         elseif ch == '\'' then
//           return ('\'', false)
//         elseif ch == '"' then
//           return ('"', false)
//         else
//           return (0, true)
//         end
//       else
//         return (0, true)
//       end
//     end
//     (v, false)

// class val LiteralCharUnicode is (Node & NodeWithValue[U32])
//   let _src_info: SrcInfo
//   let _value: U32
//   let _value_error: Bool

//   new val create(src_info': SrcInfo) =>
//     _src_info = src_info'
//     (_value, _value_error) = _get_char_value(_src_info)

//   new val from(src_info': SrcInfo, value': U32, value_error': Bool = false) =>
//     _src_info = src_info'
//     _value = value'
//     _value_error = value_error'

//   fun src_info(): SrcInfo => _src_info

//   fun eq(other: box->Node): Bool =>
//     match other
//     | let lc: LiteralCharUnicode =>
//       (this._src_info == lc._src_info) and (this._value == lc._value)
//         and (this._value_error == lc._value_error)
//     else
//       false
//     end

//   fun info(): json.Item val =>
//     recover
//       json.Object([
//         ("node", "LiteralCharUnicode")
//         ("value", if _value_error then "?ERROR?" else _value.string() end)
//       ])
//     end

//   fun value(): U32 => _value
//   fun value_error(): Bool => _value_error

//   fun tag _get_char_value(si: SrcInfo): (U32, Bool) =>
//     var v: U32 = 0
//     for ch in (si.start() + 2).values(si.next()) do
//       if (ch >= '0') and (ch <= '9') then
//         v = (v * 16) + U32.from[U8](ch - '0')
//       elseif (ch >= 'a') and (ch <= 'f') then
//         v = (v * 16) + U32.from[U8](ch - 'a') + 10
//       elseif (ch >= 'A') and (ch <= 'F') then
//         v = (v * 16) + U32.from[U8](ch - 'A') + 10
//       else
//         return (0, true)
//       end
//     end
//     (v, false)
