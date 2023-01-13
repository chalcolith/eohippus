use "itertools"

use json = "../json"

class TypeArrow is (Node & NodeWithChildren)
  let _src_info: SrcInfo
  let _lhs: Node
  let _rhs: Node
  let _children: NodeSeq

  new val create(
    src_info': SrcInfo,
    children': NodeSeq,
    lhs': Node,
    rhs': Node)
  =>
    _src_info = src_info'
    _children = children'
    _lhs = lhs'
    _rhs = rhs'

  fun src_info(): SrcInfo => _src_info

  fun info(): json.Item iso^ =>
    recover
      json.Object([
        ("node", "TypeArrow")
        ("lhs", _lhs.info())
        ("rhs", _rhs.info())
      ])
    end

  fun children(): NodeSeq => _children

  fun lhs(): Node => _lhs

  fun rhs(): Node => _rhs
