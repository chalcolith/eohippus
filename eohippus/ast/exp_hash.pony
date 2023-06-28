use json = "../json"
use types = "../types"

class val ExpHash is (Node & NodeWithChildren)
  let _src_info: SrcInfo
  let _children: NodeSeq
  let _rhs: Node

  new val create(src_info': SrcInfo, children': NodeSeq, rhs': Node) =>
    _src_info = src_info'
    _children = children'
    _rhs = rhs'

  fun src_info(): SrcInfo => _src_info

  fun info(): json.Item val =>
    recover
      json.Object([
        ("node", "ExpHash")
        ("rhs", _rhs.info())
      ])
    end

  fun children(): NodeSeq => _children

  fun rhs(): Node => _rhs
