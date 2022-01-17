use ".."

class val ErrorSection is (Node & NodeParent)
  let _src_info: SrcInfo
  let _children: NodeSeq[Node]
  let _message: String

  new val create(src_info': SrcInfo, children': NodeSeq[Node],
    message': String)
  =>
    _src_info = src_info'
    _children = children'
    _message = message'

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => true
  fun string(): String iso^ =>
    "<ERROR: " + StringUtil.escape(_message) + ">"
  fun children(): NodeSeq[Node] => _children
  fun message(): String => _message
