use json = "../json"
use ".."

class val ErrorSection is (Node & NodeWithChildren)
  let _src_info: SrcInfo
  let _children: NodeSeq
  let _message: String

  new val create(src_info': SrcInfo, children': NodeSeq, message': String)
  =>
    _src_info = src_info'
    _children = children'
    _message = message'

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => true
  fun info(): json.Item val =>
    recover
      json.Object([
        ("node", "ErrorSection")
        ("message", _message)
      ])
    end
  fun children(): NodeSeq => _children
  fun message(): String => _message
