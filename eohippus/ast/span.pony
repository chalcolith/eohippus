class val Span is Node
  let _src_info: SrcInfo

  new val create(src_info': SrcInfo) =>
    _src_info = src_info'

  fun src_info(): SrcInfo => _src_info
  fun string(): String iso^ =>
    recover
      let s = String
      s.append("<SPAN '")
      for ch in _src_info.start().values(_src_info.next()) do
        if ch == ' ' then
          s.push(' ')
        elseif ch == '\n' then
          s.append("\\n")
        elseif ch == '\r' then
          s.append("\\r")
        elseif ch == '\t' then
          s.append("\\t")
        else
          s.push(ch)
        end
      end
      s.append("'>")
      s
    end
