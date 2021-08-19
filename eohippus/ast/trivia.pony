class val TriviaWS is Node
  let _src_info: SrcInfo

  new val create(src_info': SrcInfo) =>
    _src_info = src_info'

  fun src_info(): SrcInfo => _src_info

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


class val TriviaEOL is Node
  let _src_info: SrcInfo

  new val create(src_info': SrcInfo) =>
    _src_info = src_info'

  fun src_info(): SrcInfo => _src_info

  fun string(): String iso^ =>
    recover
      String.>append("<EOL>")
    end


class val TriviaEOF is Node
  let _src_info: SrcInfo

  new val create(src_info': SrcInfo) =>
    _src_info = src_info'

  fun src_info(): SrcInfo => _src_info

  fun string(): String iso^ =>
    recover
      String.>append("<EOF>")
    end
