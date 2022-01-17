class val Trivia is (Node & NodeParent)
  let _src_info: SrcInfo
  let _children: NodeSeq[Node]

  new val create(src_info': SrcInfo, children': NodeSeq[Node]) =>
    _src_info = src_info'
    _children = children'

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => false

  fun string(): String iso^ =>
    recover
      let s = String
      s.append("<TRIVIA [ ")
      for child in _children.values() do
        let child' = recover val child.string() end
        s.append(child')
        s.append(" ")
      end
      s.append("]>")
      s
    end

  fun children(): NodeSeq[Node] => _children

class val TriviaLineComment is Node
  let _src_info: SrcInfo

  new val create(src_info': SrcInfo) =>
    _src_info = src_info'

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => false

  fun string(): String iso^ =>
    recover
      let result = String
      result.append("<LINE_COMMENT '")
      result.concat(start().values(next()))
      result.append("'>")
      result
    end

class val TriviaNestedComment is Node
  let _src_info: SrcInfo

  new val create(src_info': SrcInfo) =>
    _src_info = src_info'

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => false

  fun string(): String iso^ =>
    recover
      let result = String
      result.append("<NESTED_COMMENT '")
      result.concat(start().values(next()))
      result.append("'>")
      result
    end

class val TriviaWS is Node
  let _src_info: SrcInfo

  new val create(src_info': SrcInfo) =>
    _src_info = src_info'

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => false

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
      result.append("'>")
      result
    end

class val TriviaEOL is Node
  let _src_info: SrcInfo

  new val create(src_info': SrcInfo) =>
    _src_info = src_info'

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => false

  fun string(): String iso^ =>
    recover
      String.>append("<EOL>")
    end

class val TriviaEOF is Node
  let _src_info: SrcInfo

  new val create(src_info': SrcInfo) =>
    _src_info = src_info'

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => false

  fun string(): String iso^ =>
    recover
      String.>append("<EOF>")
    end
