
primitive Parse
  fun apply(str: String): (Item | ParseError) =>
    let parser = Parser
    for ch in str.values() do
      match parser.parse_char(ch)
      | let item: (Item | ParseError) =>
        return item
      end
    end
    match parser.parse_char(0)
    | let item: (Item | ParseError) =>
      return item
    end
    ParseError(str.size(), "unknown error")

class val ParseError
  let index: USize
  let message: String

  new val create(index': USize, message': String) =>
    index = index'
    message = message'

primitive _ExpectItem
primitive _ExpectName
primitive _ExpectColon
primitive _ExpectComma
primitive _InString
primitive _InName
primitive _InEscape
primitive _InInt
primitive _InFrac
primitive _InExp
primitive _InTrue
primitive _InFalse
primitive _InNull

type _ParseState is
  ( _ExpectItem
  | _ExpectName
  | _ExpectColon
  | _ExpectComma
  | _InString
  | _InName
  | _InEscape
  | _InInt
  | _InFrac
  | _InExp
  | _InTrue
  | _InFalse
  | _InNull )

type _TempItem is
  ( Object trn
  | Sequence trn
  | String trn
  | I128
  | F64
  | Bool
  | Null
  | U32
  | (String trn, None)
  | (F64, F64) // frac; floating point, next fractional power of 10
  | (F64, I32) ) // exp; floating point, exponent (∞ or -∞ to start)

type _TrnItem is
  ( Object trn
  | Sequence trn
  | String trn
  | I128
  | F64
  | Bool
  | Null )

class Parser
  let _ten: F64 = 10.0
  let _value_stack: Array[_TempItem] = _value_stack.create()
  var _state: _ParseState = _ExpectItem
  var _index: USize = 0
  var _line: USize = 1
  var _depth: ISize = 0
  var _bool_count: USize = 0
  var _expect_hex: USize = 0
  var _ch: U8 = 0

  let _context: Array[U8] = Array[U8].init(0, 64)
  let _context_size: USize = 64
  var _context_start: USize = 0

  new create() =>
    None

  fun ref reset() =>
    _value_stack.clear()
    _state = _ExpectItem
    _index = 0
    _depth = 0
    _bool_count = 0
    _expect_hex = 0

  fun ref parse_seq(
    seq: ReadSeq[U8],
    items: Seq[Item],
    errors: Seq[ParseError])
  =>
    for ch in seq.values() do
      match parse_char(ch)
      | let item: Item =>
        items.push(item)
      | let perr: ParseError =>
        errors.push(perr)
      end
    end

  fun ref parse_char(ch: U8): (Item val | ParseError | None) =>
    _ch = ch

    if _ch == '\n' then
      _line = _line + 1
    end

    try
      _context(_context_start)? = _ch
      _context_start = _context_start + 1
      if _context_start == _context_size then
        _context_start = 0
      end
    end

    try
      let possible_error =
        match _state
        | _ExpectItem =>
          if _is_ws(ch) and (_depth == 0) then
            _index = _index + 1
            return None
          end
          _handle_expect_item()?
        | _ExpectName => _handle_expect_name()?
        | _InInt => _handle_in_int()?
        | _InFrac => _handle_in_frac()?
        | _InExp => _handle_in_exp()?
        | _InString => _handle_in_string(false)?
        | _InEscape => _handle_in_escape()?
        | _InName => _handle_in_string(true)?
        | _InTrue => _handle_in_true()?
        | _InFalse => _handle_in_false()?
        | _InNull => _handle_in_null()?
        | _ExpectColon => _handle_expect_colon()
        | _ExpectComma => _handle_expect_comma()?
        end
      match possible_error
      | let pe: ParseError =>
        return pe
      end
    else
      return ParseError(_index, "internal error")
    end

    if _depth == 0 then
      try
        match _value_stack.pop()?
        | let obj: Object trn =>
          return consume obj
        | let seq: Sequence trn =>
          return consume seq
        | let str: String trn =>
          return consume str
        | let int: I128 =>
          return int
        | let float: F64 =>
          return float
        | let bool: Bool =>
          return bool
        | let null: Null =>
          return null
        | (let float: F64, let _: F64) =>
          return float
        | (let float: F64, let exp: I32) =>
          return _make_exp(float, exp)
        | (let _: String, let _: None) =>
          return ParseError(_index, "unterminated object")
        else
          return ParseError(_index, "internal error")
        end
      else
        return ParseError(_index, "no JSON item was present")
      end
    elseif _depth < 0 then
      return ParseError(_index, "undeflow")
    else
      _index = _index + 1
    end
    None

  fun ref _handle_expect_item(): (ParseError | None) ? =>
    if _is_ws(_ch) then
      return None
    elseif _ch == '{' then
      _value_stack.push(recover trn Object end)
      _depth = _depth + 1
      _state = _ExpectName
    elseif _ch == '[' then
      _value_stack.push(recover trn Sequence end)
      _depth = _depth + 1
      // state remains _ExpectItem
    elseif _ch == ']' then
      if _value_stack.size() == 0 then
        return _invalid_char(_index)
      end
      match _value_stack.pop()?
      | let seq: Sequence trn =>
        _add_item(consume seq)?
        _state = _ExpectComma
      else
        return _invalid_char(_index)
      end
    elseif _ch == '"' then
      _value_stack.push(recover trn String end)
      _depth = _depth + 1
      _state = _InString
    elseif _ch == '-' then
      _value_stack.push(I128.min_value())
      _depth = _depth + 1
      _state = _InInt
    elseif _ch == '+' then
      _value_stack.push(I128.max_value())
      _depth = _depth + 1
      _state = _InInt
    elseif _is_num(_ch) then
      _value_stack.push(I128.from[U8](_ch - '0'))
      _depth = _depth + 1
      _state = _InInt
    elseif _ch == 't' then
      _depth = _depth + 1
      _bool_count = 1
      _state = _InTrue
    elseif _ch == 'f' then
      _depth = _depth + 1
      _bool_count = 1
      _state = _InFalse
    elseif _ch == 'n' then
      _depth = _depth + 1
      _bool_count = 1
      _state = _InNull
    else
      return _invalid_char(_index)
    end
    None

  fun ref _handle_expect_name(): (ParseError | None) ? =>
    if _is_ws(_ch) then
      return None
    elseif _ch == '"' then
      _value_stack.push(recover trn String end)
      _state = _InName
    elseif _ch == '}' then
      _add_item(_value_stack.pop()? as Object trn^)?
      _state = _ExpectComma
    else
      return _invalid_char(_index)
    end
    None

  fun ref _handle_in_int(): (ParseError | None) ? =>
    if _is_num(_ch) then
      let int = _value_stack.pop()? as I128
      if int == I128.max_value() then
        _value_stack.push(I128.from[U8](_ch - '0'))
      elseif int == I128.min_value() then
        _value_stack.push(-I128.from[U8](_ch - '0'))
      elseif int < 0 then
        _value_stack.push(-((-int * 10) + I128.from[U8](_ch - '0')))
      else
        _value_stack.push((int * 10) + I128.from[U8](_ch - '0'))
      end
    elseif _is_ws(_ch) then
      let int = _value_stack.pop()? as I128
      _add_item(int)?
      _state = _ExpectComma
    elseif _ch == ',' then
      let int = _value_stack.pop()? as I128
      _add_item(int)?
      _state = _expect_next()?
    elseif _ch == '.' then
      let int = _value_stack.pop()? as I128
      let float = F64.from[I128](int)
      _value_stack.push((float, F64(0.1)))
      _state = _InFrac
    elseif (_ch == 'e') or (_ch == 'E') then
      let int = _value_stack.pop()? as I128
      let float = F64.from[I128](int)
      _value_stack.push((float, I32.max_value()))
      _state = _InExp
    elseif _ch == ']' then
      let int = _value_stack.pop()? as I128
      _add_item(int)?
      match _value_stack.pop()?
      | let seq: Sequence trn =>
        _add_item(consume seq)?
        _state = _ExpectComma
      else
        return _invalid_char(_index)
      end
    elseif _ch == '}' then
      let int = _value_stack.pop()? as I128
      _add_item(int)?
      _add_item(_value_stack.pop()? as Object trn^)?
      _state = _ExpectComma
    else
      return _invalid_char(_index)
    end
    None

  fun ref _expect_next(): _ParseState ? =>
    if _value_stack.size() > 0 then
      match _value_stack(_value_stack.size() - 1)?
      | let _: Object trn =>
        return _ExpectName
      end
    end
    _ExpectItem

  fun ref _handle_in_frac(): (ParseError | None) ? =>
    if _is_num(_ch) then
      (let float, let pow) = _value_stack.pop()? as (F64, F64)
      let float' =
        if float < 0.0 then
          -(-float + (pow * F64.from[U8](_ch - '0')))
        else
          float + (pow * F64.from[U8](_ch - '0'))
        end
      _value_stack.push((float', pow / 10.0))
    elseif (_ch == 'e') or (_ch == 'E') then
      (let float, _) = _value_stack.pop()? as (F64, F64)
      _value_stack.push((float, I32.max_value()))
      _state = _InExp
    elseif _is_ws(_ch) then
      (let float, _) = _value_stack.pop()? as (F64, F64)
      _add_item(float)?
      _state = _ExpectComma
    elseif _ch == ',' then
      (let float, _) = _value_stack.pop()? as (F64, F64)
      _add_item(float)?
      _state = _expect_next()?
    elseif _ch == ']' then
      (let float, _) = _value_stack.pop()? as (F64, F64)
      _add_item(float)?
      match _value_stack.pop()?
      | let seq: Sequence trn =>
        _add_item(consume seq)?
        _state = _ExpectComma
      else
        return _invalid_char(_index)
      end
    elseif _ch == '}' then
      let int = _value_stack.pop()? as I128
      _add_item(int)?
      _add_item(_value_stack.pop()? as Object trn^)?
      _state = _ExpectComma
    else
      return _invalid_char(_index)
    end
    None

  fun ref _handle_in_exp(): (ParseError | None) ? =>
    if _ch == '+' then
      return None
    elseif _ch == '-' then
      (let float, let exp) = _value_stack.pop()? as (F64, I32)
      _value_stack.push((float, I32.min_value()))
    elseif _is_num(_ch) then
      (let float, let exp) = _value_stack.pop()? as (F64, I32)
      if exp == I32.max_value() then
        _value_stack.push((float, I32.from[U8](_ch - '0')))
      elseif exp == I32.min_value() then
        _value_stack.push((float, -I32.from[U8](_ch - '0')))
      elseif exp < 0 then
        _value_stack.push((float, -((-exp * 10) + I32.from[U8](_ch - '0'))))
      else
        _value_stack.push((float, (exp * 10) + I32.from[U8](_ch - '0')))
      end
    elseif _is_ws(_ch) then
      (let float, let exp) = _value_stack.pop()? as (F64, I32)
      _add_item(_make_exp(float, exp))?
      _state = _ExpectComma
    elseif _ch == ',' then
      (let float, let exp) = _value_stack.pop()? as (F64, I32)
      _add_item(_make_exp(float, exp))?
      _state = _expect_next()?
    elseif _ch == ']' then
      (let float, let exp) = _value_stack.pop()? as (F64, I32)
      _add_item(_make_exp(float, exp))?
      match _value_stack.pop()?
      | let seq: Sequence trn =>
        _add_item(consume seq)?
        _state = _ExpectComma
      else
        return _invalid_char(_index)
      end
    elseif _ch == '}' then
      let int = _value_stack.pop()? as I128
      _add_item(int)?
      _add_item(_value_stack.pop()? as Object trn^)?
      _state = _ExpectComma
    else
      return _invalid_char(_index)
    end
    None

  fun ref _handle_in_string(is_name: Bool): (ParseError | None) ? =>
    if _ch == '"' then
      if is_name then
        _value_stack.push((_value_stack.pop()? as String trn^, None))
        _state = _ExpectColon
      else
        _add_item(_value_stack.pop()? as String trn^)?
        _state = _ExpectComma
      end
    elseif (_ch == '\\') and (not is_name) then
      _state = _InEscape
    else
      (_value_stack(_value_stack.size() - 1)? as String trn^).push(_ch)
    end
    None

  fun ref _handle_in_escape(): (ParseError | None) ? =>
    if _expect_hex > 0 then
      var cur = _value_stack.pop()? as U32
      let hexit =
        if (_ch >= '0') and (_ch <= '9') then
          U32.from[U8](_ch - '0')
        elseif (_ch >= 'a') and (_ch <= 'f') then
          U32.from[U8]((_ch - 'a') + 10)
        elseif (_ch >= 'A') and (_ch <= 'F') then
          U32.from[U8]((_ch - 'A') + 10)
        else
          return ParseError(_index, "invalid hexadecimal digit")
        end
      cur = (cur * 16) + hexit
      _expect_hex = _expect_hex - 1
      if _expect_hex > 0 then
        _value_stack.push(cur)
      else
        (_value_stack(_value_stack.size() - 1)? as String trn^).push_utf32(cur)
        _state = _InString
      end
    else
      let ch' =
        match _ch
        | 'a' => '\a'
        | 'b' => '\b'
        | 'e' => '\e'
        | 'f' => '\f'
        | 'n' => '\n'
        | 'r' => '\r'
        | 't' => '\t'
        | 'v' => '\v'
        | '\\' => '\\'
        | '0' => '\0'
        | '"' => '"'
        | 'x' =>
          _value_stack.push(U32(0))
          _expect_hex = 2
          return None
        | 'u' =>
          _value_stack.push(U32(0))
          _expect_hex = 4
          return None
        else
          _ch
        end
      (_value_stack(_value_stack.size() - 1)? as String trn^).push(ch')
      _state = _InString
    end
    None

  fun ref _handle_in_true(): (ParseError | None) ? =>
    match _bool_count
    | 1 =>
      if _ch == 'r' then
        _bool_count = 2
        return None
      end
    | 2 =>
      if _ch == 'u' then
        _bool_count = 3
        return None
      end
    | 3 =>
      if _ch == 'e' then
        _add_item(true)?
        _state = _ExpectComma
        return None
      end
    end
    ParseError(_index, "invalid character")

  fun ref _handle_in_false(): (ParseError | None) ? =>
    match _bool_count
    | 1 =>
      if _ch == 'a' then
        _bool_count = 2
        return None
      end
    | 2 =>
      if _ch == 'l' then
        _bool_count = 3
        return None
      end
    | 3 =>
      if _ch == 's' then
        _bool_count = 4
        return None
      end
    | 4 =>
      if _ch == 'e' then
        _add_item(false)?
        _state = _ExpectComma
        return None
      end
    end
    ParseError(_index, "invalid character")

  fun ref _handle_in_null(): (ParseError | None) ? =>
    match _bool_count
    | 1 =>
      if _ch == 'u' then
        _bool_count = 2
        return None
      end
    | 2 =>
      if _ch == 'l' then
        _bool_count = 3
        return None
      end
    | 3 =>
      if _ch == 'l' then
        _add_item(Null)?
        _state = _ExpectComma
        return None
      end
    end
    ParseError(_index, "invalid character")

  fun ref _handle_expect_colon(): (ParseError | None) =>
    if _is_ws(_ch) then
      return None
    elseif _ch == ':' then
      _state = _ExpectItem
    else
      return ParseError(_index, "expected a colon")
    end
    None

  fun ref _handle_expect_comma(): (ParseError | None) ? =>
    if _is_ws(_ch) then
      return None
    elseif _ch == ',' then
      _state = _expect_next()?
    elseif _ch == ']' then
      try
        _add_item(_value_stack.pop()? as Sequence trn^)?
      else
        return ParseError(_index, "unexpected ']'")
      end
    elseif _ch == '}' then
      try
        _add_item(_value_stack.pop()? as Object trn^)?
      else
        return ParseError(_index, "unexpected '}'")
      end
    else
      return ParseError(_index, "expected a comma")
    end
    None

  fun ref _add_item(item: _TrnItem) ? =>
    if _value_stack.size() == 0 then
      _value_stack.push(consume item)
    else
      match _value_stack(_value_stack.size() - 1)?
      | let seq: Sequence trn =>
        seq.push(consume item)
      | (let name: String trn, _) =>
        (_value_stack(_value_stack.size() - 2)? as Object trn)
          .update(consume name, consume item)
        _value_stack.pop()?
      else
        error
      end
    end
    _depth = _depth - 1

  fun _make_exp(float: F64, exp: I32): F64 =>
    float * _ten.powi(exp)

  fun _invalid_char(index: USize): ParseError =>
    let message: String trn = String
    message.append("invalid character '")
    message.push(_ch)
    message.append("' in line " + _line.string() + "; expecting ")
    message.append(
      match _state
      | _ExpectItem => "an item"
      | _ExpectName => "a name"
      | _ExpectColon => "a colon"
      | _ExpectComma => "a comma"
      | _InString => "a string"
      | _InName => "a name"
      | _InEscape => "an escape"
      | _InInt => "an int"
      | _InFrac => "a frac"
      | _InExp => "an exponent"
      | _InTrue => "true"
      | _InFalse => "false"
      | _InNull => "null"
      end)
    message.append("; context: '")
    var i: USize = 0
    while i < _context_size do
      try
        let ch = _context((i + _context_start) % _context_size)?
        if ch != 0 then
          message.push(ch)
        end
        i = i + 1
      end
    end
    message.append("'")
    ParseError(index, consume message)

  fun _is_num(ch: U8): Bool =>
    (ch >= '0') and (ch <= '9')

  fun _is_ws(ch: U8): Bool =>
    (ch == ' ') or (ch == '\t') or (ch == '\r') or (ch == '\n') or (ch == 0)
