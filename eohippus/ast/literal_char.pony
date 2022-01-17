use parser = "../parser"
use types = "../types"

class val LiteralChar is
  (Node & NodeTyped[LiteralChar] & NodeValued[U32] & NodeParent)

  let _src_info: SrcInfo
  let _ast_type: (types.AstType | None)
  let _value: U32
  let _value_error: Bool
  let _children: NodeSeq[Node]

  new val create(src_info': SrcInfo, children': NodeSeq[Node]) =>
    _src_info = src_info'
    _ast_type = None
    (_value, _value_error) = _get_char_value(children')
    _children = children'

  new val from(src_info': SrcInfo, value': U32, value_error': Bool = false) =>
    _src_info = src_info'
    _ast_type = None
    _value = value'
    _value_error = value_error'
    _children = recover Array[Node] end

  new val _with_ast_type(char: LiteralChar, ast_type': types.AstType) =>
    _src_info = char.src_info()
    _ast_type = ast_type'
    _value = char.value()
    _value_error = char.value_error()
    _children = char.children()

  fun src_info(): SrcInfo => _src_info

  fun has_error(): Bool => _value_error

  fun eq(other: box->Node): Bool =>
    match other
    | let lc: LiteralChar =>
      (this._src_info == lc._src_info) and (this._value == lc._value)
        and (this._value_error == lc._value_error)
    else
      false
    end

  fun string(): String iso^ =>
    let type_name =
      match _ast_type
      | let type': types.AstType =>
        type'.string()
      else
        "?LiteralChar?"
      end
    "<LIT: " + type_name + " = " + _value.string()
      + (if _value_error then " ?ERROR?" else "" end) + ">"

  fun ast_type(): (types.AstType | None) => _ast_type
  fun val with_ast_type(ast_type': types.AstType): LiteralChar =>
    LiteralChar._with_ast_type(this, ast_type')

  fun value(): U32 => _value
  fun value_error(): Bool => _value_error

  fun children(): NodeSeq[Node] => _children

  fun tag _get_char_value(children': NodeSeq[Node]): (U32, Bool) =>
    var v: U32 = 0
    for child' in children'.values() do
      match child'
      | let lce: LiteralCharEscape =>
        if lce.value_error() then
          return (0, true)
        else
          v = (v << 8) or lce.value()
        end
      | let span: Span =>
        for ch in span.src_info().start().values(span.src_info().next()) do
          if (ch and 0b11111000) == 0b11110000 then
            v = (v << 3) or U32.from[U8](ch and 0b00000111)
          elseif (ch and 0b11100000) == 0b11100000 then
            v = (v << 4) or U32.from[U8](ch and 0b00001111)
          elseif (ch and 0b11100000) == 0b11000000 then
            v = (v << 5) or U32.from[U8](ch and 0b00011111)
          elseif (ch and 0b11000000) == 0b10000000 then
            v = (v << 6) or U32.from[U8](ch and 0b00111111)
          else
            v = (v << 8) or U32.from[U8](ch)
          end
        end
      end
    end
    (v, false)

class val LiteralCharEscape is (Node & NodeValued[U32])
  let _src_info: SrcInfo
  let _value: U32
  let _value_error: Bool

  new val create(src_info': SrcInfo) =>
    _src_info = src_info'
    (_value, _value_error) = _get_char_value(_src_info)

  new val from(src_info': SrcInfo, value': U32, value_error': Bool = false) =>
    _src_info = src_info'
    _value = value'
    _value_error = value_error'

  fun src_info(): SrcInfo => _src_info
  fun eq(other: box->Node): Bool =>
    match other
    | let lc: LiteralCharEscape =>
      (this._src_info == lc._src_info) and (this._value == lc._value)
        and (this._value_error == lc._value_error)
    else
      false
    end
  fun string(): String iso^ =>
    "<ESC: " + _value.string()
      + (if _value_error then " ?ERROR?" else "" end) + ">"

  fun value(): U32 => _value
  fun value_error(): Bool => _value_error

  fun tag _get_char_value(si: SrcInfo): (U32, Bool) =>
    var begin = true
    var is_slash = false
    var is_hex = false
    var v: U32 = 0
    for ch in si.start().values(si.next()) do
      if begin then
        begin = false
        if ch == '\\' then
          is_slash = true
          continue
        end
      elseif is_hex then
        if (ch >= '0') and (ch <= '9') then
          v = (v * 16) + U32.from[U8](ch - '0')
        elseif (ch >= 'a') and (ch <= 'f') then
          v = (v * 16) + U32.from[U8](ch - 'a') + 10
        elseif (ch >= 'A') and (ch <= 'F') then
          v = (v * 16) + U32.from[U8](ch - 'A') + 10
        else
          return (0, true)
        end
      elseif is_slash then
        if (ch == 'x') or (ch == 'X') then
          is_hex = true
          continue
        elseif ch == 'a' then
          return ('\a', false)
        elseif ch == 'b' then
          return ('\b', false)
        elseif ch == 'e' then
          return ('\e', false)
        elseif ch == 'f' then
          return ('\f', false)
        elseif ch == 'n' then
          return ('\n', false)
        elseif ch == 'r' then
          return ('\r', false)
        elseif ch == '\t' then
          return ('\t', false)
        elseif ch == '\v' then
          return ('\v', false)
        elseif ch == '\\' then
          return ('\\', false)
        elseif ch == '0' then
          return ('\0', false)
        elseif ch == '\'' then
          return ('\'', false)
        elseif ch == '"' then
          return ('"', false)
        else
          return (0, true)
        end
      else
        return (0, true)
      end
    end
    (v, false)

class val LiteralCharUnicode is (Node & NodeValued[U32])
  let _src_info: SrcInfo
  let _value: U32
  let _value_error: Bool

  new val create(src_info': SrcInfo) =>
    _src_info = src_info'
    (_value, _value_error) = _get_char_value(_src_info)

  new val from(src_info': SrcInfo, value': U32, value_error': Bool = false) =>
    _src_info = src_info'
    _value = value'
    _value_error = value_error'

  fun src_info(): SrcInfo => _src_info
  fun eq(other: box->Node): Bool =>
    match other
    | let lc: LiteralCharUnicode =>
      (this._src_info == lc._src_info) and (this._value == lc._value)
        and (this._value_error == lc._value_error)
    else
      false
    end
  fun string(): String iso^ =>
    "<ESC_UNI: " + _value.string()
      + (if _value_error then " ?ERROR?" else "" end) + ">"

  fun value(): U32 => _value
  fun value_error(): Bool => _value_error

  fun tag _get_char_value(si: SrcInfo): (U32, Bool) =>
    var v: U32 = 0
    for ch in (si.start() + 2).values(si.next()) do
      if (ch >= '0') and (ch <= '9') then
        v = (v * 16) + U32.from[U8](ch - '0')
      elseif (ch >= 'a') and (ch <= 'f') then
        v = (v * 16) + U32.from[U8](ch - 'a') + 10
      elseif (ch >= 'A') and (ch <= 'F') then
        v = (v * 16) + U32.from[U8](ch - 'A') + 10
      else
        return (0, true)
      end
    end
    (v, false)
