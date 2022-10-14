use parser = "../parser"
use types = "../types"

primitive DecimalInteger
primitive HexadecimalInteger
primitive BinaryInteger
type LiteralIntegerKind is (DecimalInteger | HexadecimalInteger | BinaryInteger)

class val LiteralInteger is
  (Node & NodeTyped[LiteralInteger] & NodeValued[U128])

  let _kind: LiteralIntegerKind

  let _src_info: SrcInfo
  let _ast_type: (types.AstType | None)

  let _value: U128
  let _value_error: Bool

  new val create(src_info': SrcInfo, kind': LiteralIntegerKind) =>
    _src_info = src_info'
    _ast_type = None
    _kind = kind'
    (_value, _value_error) = _get_num_value(_src_info, _kind)

  new val from(src_info': SrcInfo, kind': LiteralIntegerKind, value': U128) =>
    _src_info = src_info'
    _ast_type = None
    _kind = kind'
    _value = value'
    _value_error = false

  new val _with_ast_type(orig: LiteralInteger, ast_type': types.AstType) =>
    _src_info = orig._src_info
    _ast_type = ast_type'
    _kind = orig._kind
    _value = orig._value
    _value_error = orig._value_error

  fun kind(): LiteralIntegerKind => _kind

  fun src_info(): SrcInfo => _src_info

  fun has_error(): Bool => _value_error

  fun eq(other: box->Node): Bool =>
    match other
    | let li: box->LiteralInteger =>
      (this._src_info == li._src_info)
        and (this._kind is li._kind) and (this._value == li._value)
        and (this._value_error == li._value_error)
    else
      false
    end
  fun ne(other: box->Node): Bool => not this.eq(other)
  fun get_string(indent: String): String =>
    let type_name =
      match _ast_type
      | let type': types.AstType =>
        type'.string()
      else
        "?LiteralInteger?"
      end
    indent + "<LIT type=\"" + type_name + "\" value=\"" +
      (if _value_error then "?ERROR?" else _value.string() end) + "\"/>"

  fun ast_type(): (types.AstType | None) => _ast_type
  fun val with_ast_type(ast_type': types.AstType): LiteralInteger =>
    LiteralInteger._with_ast_type(this, ast_type')

  fun value(): U128 => _value
  fun value_error(): Bool => _value_error

  fun tag _get_num_value(si: SrcInfo, k: LiteralIntegerKind): (U128, Bool) =>
    var n: U128 = 0
    var err: Bool = false
    try
      match k
      | DecimalInteger =>
        for ch in si.start().values(si.next()) do
          if ch != '_' then
            n = (n *? 10) + (U128.from[U8](ch) - '0')
          end
        end
      | HexadecimalInteger =>
        for ch in (si.start() + 2).values(si.next()) do
          if (ch >= '0') and (ch <= '9') then
            n = (n *? 16) + (U128.from[U8](ch) - '0')
          elseif (ch >= 'a') and (ch <= 'z') then
            n = (n *? 16) + (U128.from[U8](ch) - 'a') + 10
          elseif (ch >= 'A') and (ch <= 'Z') then
            n = (n *? 16) + (U128.from[U8](ch) - 'A') + 10
          end
        end
      | BinaryInteger =>
        for ch in (si.start() + 2).values(si.next()) do
          if ch == '1' then
            n = (n *? 2) + 1
          elseif ch == '0' then
            n = (n *? 2)
          end
        end
      end
    else
      err = true
    end
    (n, err)
