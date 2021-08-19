use "kiuatan"

class val AstTriviaWS[CH: ((U8 | U16) & UnsignedInteger[CH])] is AstNode[CH]
  let _src_info: SrcInfo[CH]

  new val create(src_info': SrcInfo[CH]) =>
    _src_info = src_info'

  fun src_info(): SrcInfo[CH] => _src_info

  fun string(): String iso^ =>
    recover
      let result = String
      result.append("<WS '")
      for ch in start().values(next()) do
        if ch.u8() == ' ' then
          result.append(" ")
        elseif ch.u8() == '\t' then
          result.append("\\t")
        else
          result.append("?")
        end
      end
      result.>append("'>")
    end


class val AstTriviaEOL[CH] is AstNode[CH]
  let _src_info: SrcInfo[CH]

  new val create(src_info': SrcInfo[CH]) =>
    _src_info = src_info'

  fun src_info(): SrcInfo[CH] => _src_info

  fun string(): String iso^ =>
    recover
      String.>append("<EOL>")
    end


class val AstTriviaEOF[CH] is AstNode[CH]
  let _src_info: SrcInfo[CH]

  new val create(src_info': SrcInfo[CH]) =>
    _src_info = src_info'

  fun src_info(): SrcInfo[CH] => _src_info

  fun string(): String iso^ =>
    recover
      String.>append("<EOF>")
    end
