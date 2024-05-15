use "format"

primitive StringUtil
  fun is_ws(ch: U8): Bool =>
    (ch == ' ') or (ch == '\t') or (ch == '\r') or (ch == '\n') or (ch == 0)

  fun escape(orig: String box): String iso^ =>
    """Returns an "escaped" version of a string.""""

    let result: String iso = String(orig.size())
    for rune in orig.runes() do
      if rune < ' ' then
        let ch = U8.from[U32](rune)
        if rune == '\a' then
          result.append("\\a")
        elseif rune == '\b' then
          result.append("\\b")
        elseif rune == '\e' then
          result.append("\\e")
        elseif rune == '\f' then
          result.append("\\f")
        elseif rune == '\n' then
          result.append("\\n")
        elseif rune == '\r' then
          result.append("\\r")
        elseif rune == '\t' then
          result.append("\\t")
        elseif rune == '\v' then
          result.append("\\v")
        elseif rune == '\0' then
          result.append("\\0")
        elseif rune == '"' then
          result.append("\\\"")
        else
          result.append("\\x")
          result.append(Format.int[U32](rune, FormatHexBare where prec = 2))
        end
      elseif rune == '\\' then
        result.append("\\\\")
      elseif rune == '"' then
        result.append("\\\"")
      elseif rune < 128 then
        result.push(U8.from[U32](rune))
      elseif rune < 0xff then
        result.append("\\x")
        result.append(Format.int[U32](rune, FormatHexBare where prec = 2))
      elseif rune < 0xffff then
        result.append("\\u")
        result.append(Format.int[U32](rune, FormatHexBare where prec = 4))
      else
        result.append("\\u")
        result.append(Format.int[U32](rune, FormatHexBare where prec = 6))
      end
    end
    consume result

  fun url_encode(str: String box): String =>
    let result: String trn = String
    for ch in str.values() do
      if
        ( (ch >= 'a') and (ch <= 'z') ) or
        ( (ch >= 'A') and (ch <= 'Z') ) or
        ( (ch >= '0') and (ch <= '9') ) or
        ( ch == '/' ) or (ch == ':')
      then
        result.push(ch)
      else
        result.push('%')
        result.append(Format.int[U8](ch, FormatHexBare where prec = 2))
      end
    end
    consume result

  fun url_decode(str: String): String =>
    let result: String trn = String
    var i: USize = 0
    while i < str.size() do
      let ch: U8 = try str(i)? else '?' end
      if (ch == '%') and ((i + 2) < str.size()) then
        try
          let hex = str.trim(i + 1, i + 3)
          result.push(hex.u8(16)?)
          i = i + 2
        else
          result.push(ch)
        end
      else
        result.push(ch)
      end
      i = i + 1
    end
    consume result
