use ".."

class val Trivia is (Node & NodeParent)
  let _src_info: SrcInfo
  let _children: NodeSeq

  new val create(src_info': SrcInfo, children': NodeSeq) =>
    _src_info = src_info'
    _children = children'

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => false

  fun get_string(indent: String): String =>
    recover val
      let s = String
      s.append(indent)
      s.append("<TRIVIA [ ")
      for child in _children.values() do
        s.append(child.get_string(""))
        s.append(" ")
      end
      s.append("]>")
      s
    end

  fun children(): NodeSeq => _children

class val TriviaLineComment is Node
  let _src_info: SrcInfo

  new val create(src_info': SrcInfo) =>
    _src_info = src_info'

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => false

  fun get_string(indent: String): String =>
    recover val
      let result = String
      result.append(indent)
      result.append("<LINE_COMMENT '")
      result.append(StringUtil.escape(
        recover val String.>concat(start().values(next())) end))
      result.append("'>")
      result
    end

class val TriviaNestedComment is Node
  let _src_info: SrcInfo

  new val create(src_info': SrcInfo) =>
    _src_info = src_info'

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => false

  fun get_string(indent: String): String =>
    recover val
      let result = String
      result.append(indent)
      result.append("<NESTED_COMMENT '")
      result.append(StringUtil.escape(
        recover val String.>concat(start().values(next())) end))
      result.append("'>")
      result
    end

class val TriviaWS is Node
  let _src_info: SrcInfo

  new val create(src_info': SrcInfo) =>
    _src_info = src_info'

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => false

  fun get_string(indent: String): String =>
    recover val
      let result = String
      result.append(indent)
      result.append("<WS '")
      result.append(StringUtil.escape(
        recover val String.>concat(start().values(next())) end))
      result.append("'>")
      result
    end

class val TriviaEOL is Node
  let _src_info: SrcInfo

  new val create(src_info': SrcInfo) =>
    _src_info = src_info'

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => false

  fun get_string(indent: String): String =>
    indent + "<EOL>"

class val TriviaEOF is Node
  let _src_info: SrcInfo

  new val create(src_info': SrcInfo) =>
    _src_info = src_info'

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => false

  fun get_string(indent: String): String =>
    indent + "<EOF>"
