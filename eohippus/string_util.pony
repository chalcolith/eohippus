use "format"

primitive StringUtil
  fun escape(orig: String): String iso^ =>
    recover
      let result = String(orig.size())
      for rune in orig.runes() do
        if rune < ' ' then
          let ch = U8.from[U32](rune)
          if rune == '\a' then
            result.push("\\a")
          elseif rune == '\b' then
            result.push("\\b")
          elseif rune == '\e' then
            result.push("\\e")
          elseif rune == '\f' then
            result.push("\\f")
          elseif rune == '\n' then
            result.push("\\n")
          elseif rune == '\r' then
            result.push("\\r")
          elseif rune == '\t' then
            result.push("\\t")
          elseif rune == '\v' then
            result.push("\\v")
          elseif rune == '\\' then
            result.push("\\\\")
          elseif rune == '\0' then
            result.push("\\0")
          elseif rune == '\"' then
            result.push("\\\"")
          else
            result.append("\\x")
            result.append(Format.int[U32](FormatHexBare where prec = 2))
          end
        elseif rune < 128 then
          result.push(U8.from[U32](rune))
        elseif rune < 0xff then
          result.append("\\x")
          result.append(Format.int[U32](FormatHexBare where prec = 2))
        elseif rune < 0xffff
          result.append("\\u")
          result.append(Format.int[U32](FormatHexBare where prec = 4))
        else
          result.append("\\u")
          result.append(Format.int[U32](FormatHexBare where prec = 6))
        end
      end
      result
    end
