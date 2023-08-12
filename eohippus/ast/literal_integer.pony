use json = "../json"

primitive DecimalInteger
primitive HexadecimalInteger
primitive BinaryInteger
type LiteralIntegerKind is (DecimalInteger | HexadecimalInteger | BinaryInteger)

class val LiteralInteger is NodeDataWithValue[U128]
  let _value: U128
  let kind: LiteralIntegerKind

  new create(value': U128, kind': LiteralIntegerKind) =>
    _value = value'
    kind = kind'

  fun name(): String => "LiteralInteger"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    let kind_str =
      match kind
      | DecimalInteger => "DecimalInteger"
      | HexadecimalInteger => "HexadecimalInteger"
      | BinaryInteger => "BinaryInteger"
      end
    props.push(("kind", kind_str))
    props.push(("value", I128.from[U128](_value)))

  fun value(): U128 => _value

// class val LiteralInteger is
//   (Node & NodeWithType[LiteralInteger] & NodeWithTrivia & NodeWithValue[U128])
//   let _src_info: SrcInfo
//   let _ast_type: (types.AstType | None)
//   let _body: Span
//   let _post_trivia: Trivia
//   let _value: U128
//   let _value_error: Bool
//   let _kind: LiteralIntegerKind

//   new val create(src_info': SrcInfo, post_trivia': Trivia,
//     kind': LiteralIntegerKind)
//   =>
//     _src_info = src_info'
//     _ast_type = None
//     _body = Span(SrcInfo(src_info'.locator(), src_info'.start(),
//       post_trivia'.src_info().start()))
//     _post_trivia = post_trivia'
//     (_value, _value_error) = _get_num_value(_src_info, kind')
//     _kind = kind'

//   new val from(src_info': SrcInfo, value': U128, kind': LiteralIntegerKind) =>
//     _src_info = src_info'
//     _ast_type = None
//     _body = Span(SrcInfo(src_info'.locator(), src_info'.start(),
//       src_info'.next()))
//     _post_trivia = Trivia(SrcInfo(src_info'.locator(), src_info'.next(),
//       src_info'.next()), [])
//     _value = value'
//     _value_error = false
//     _kind = kind'

//   new val _with_ast_type(orig: LiteralInteger, ast_type': types.AstType) =>
//     _src_info = orig._src_info
//     _ast_type = ast_type'
//     _kind = orig._kind
//     _body = orig._body
//     _post_trivia = orig._post_trivia
//     _value = orig._value
//     _value_error = orig._value_error

//   fun src_info(): SrcInfo => _src_info
//   fun has_error(): Bool => _value_error
//   fun eq(other: box->Node): Bool =>
//     match other
//     | let li: box->LiteralInteger =>
//       (this._src_info == li._src_info)
//         and (this._kind is li._kind) and (this._value == li._value)
//         and (this._value_error == li._value_error)
//     else
//       false
//     end
//   fun ne(other: box->Node): Bool => not this.eq(other)

//   fun info(): json.Item val =>
//     recover
//       let type_name =
//         match _ast_type
//         | let type': types.AstType =>
//           type'.string()
//         else
//           "?LiteralInteger?"
//         end
//       let kind_name =
//         match _kind
//         | DecimalInteger => "decimal"
//         | HexadecimalInteger => "hexadecimal"
//         | BinaryInteger => "binary"
//         end
//       json.Object([
//         ("node", "LiteralInteger")
//         ("type", type_name)
//         ("kind", kind_name)
//         ("value", if _value_error then "?ERROR?" else _value.string() end)
//       ])
//     end

//   fun ast_type(): (types.AstType | None) => _ast_type
//   fun val with_ast_type(ast_type': types.AstType): LiteralInteger =>
//     LiteralInteger._with_ast_type(this, ast_type')
//   fun body(): Span => _body
//   fun post_trivia(): Trivia => _post_trivia
//   fun value(): U128 => _value
//   fun value_error(): Bool => _value_error
//   fun kind(): LiteralIntegerKind => _kind

//   fun tag _get_num_value(si: SrcInfo, k: LiteralIntegerKind): (U128, Bool) =>
//     var n: U128 = 0
//     var err: Bool = false
//     try
//       match k
//       | DecimalInteger =>
//         for ch in si.start().values(si.next()) do
//           if (ch >= '0') and (ch <= '9') then
//             n = (n *? 10) + (U128.from[U8](ch) - '0')
//           end
//         end
//       | HexadecimalInteger =>
//         for ch in (si.start() + 2).values(si.next()) do
//           if (ch >= '0') and (ch <= '9') then
//             n = (n *? 16) + (U128.from[U8](ch) - '0')
//           elseif (ch >= 'a') and (ch <= 'f') then
//             n = (n *? 16) + (U128.from[U8](ch) - 'a') + 10
//           elseif (ch >= 'A') and (ch <= 'F') then
//             n = (n *? 16) + (U128.from[U8](ch) - 'A') + 10
//           end
//         end
//       | BinaryInteger =>
//         for ch in (si.start() + 2).values(si.next()) do
//           if ch == '1' then
//             n = (n *? 2) + 1
//           elseif ch == '0' then
//             n = (n *? 2)
//           end
//         end
//       end
//     else
//       err = true
//     end
//     (n, err)
