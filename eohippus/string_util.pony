use "format"

primitive StringUtil
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
        elseif rune == '\\' then
          result.append("\\\\")
        elseif rune == '\0' then
          result.append("\\0")
        elseif rune == '"' then
          result.append("\\\"")
        else
          result.append("\\x")
          result.append(Format.int[U32](rune, FormatHexBare where prec = 2))
        end
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
