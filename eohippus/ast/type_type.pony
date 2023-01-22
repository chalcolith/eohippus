use "itertools"

use json = "../json"

class val TypeType is (Node & NodeWithChildren)
  let _src_info: SrcInfo
  let _lhs: Node
  let _rhs: (Node | None)
  let _children: NodeSeq

  new val create(
    src_info': SrcInfo,
    children': NodeSeq,
    lhs': Node,
    rhs': (Node | None))
  =>
    _src_info = src_info'
    _children = children'
    _lhs = lhs'
    _rhs = rhs'

  fun src_info(): SrcInfo => _src_info

  fun info(): json.Item val =>
    recover
      let items: Array[(String, json.Item)] = [
        ("node", "TypeArrow")
        ("lhs", _lhs.info())
      ]
      match _rhs
      | let rhs': Node =>
        items.push(("rhs", rhs'.info()))
      end
      json.Object(items)
    end

  fun children(): NodeSeq => _children

  fun lhs(): Node => _lhs

  fun rhs(): (Node | None) => _rhs

class val TypeAtom is (Node & NodeWithChildren)
  let _src_info: SrcInfo
  let _children: NodeSeq

  new val create(src_info': SrcInfo, children': NodeSeq) =>
    _src_info = src_info'
    _children = children'

  fun src_info(): SrcInfo => _src_info

  fun info(): json.Item val =>
    recover _info_with_children("TypeAtom") end

  fun children(): NodeSeq => _children

class val TypeTuple is (Node & NodeWithChildren)
  let _src_info: SrcInfo
  let _children: NodeSeq
  let _types: NodeSeq[TypeAtom]

  new val create(src_info': SrcInfo, children': NodeSeq) =>
    _src_info = src_info'
    _children = children'
    _types =
      recover val
        Array[TypeAtom].>concat(
          Iter[Node](_children.values())
            .filter_map[TypeAtom]({(child) => try child as TypeAtom end }))
      end

  fun src_info(): SrcInfo => _src_info

  fun info(): json.Item val =>
    let types' =
      recover val
        json.Sequence(Array[json.Item].>concat(
          Iter[TypeAtom](_types.values())
          .map[json.Item]({(t) => t.info() })))
      end
    recover
      json.Object([
        ("node", "TypeTuple")
        ("types", types')
      ])
    end

  fun children(): NodeSeq => _children

  fun types(): NodeSeq[TypeAtom] => _types

class val TypeInfix is (Node & NodeWithChildren)
  let _src_info: SrcInfo
  let _children: NodeSeq
  let _lhs: Node
  let _op: Node
  let _rhs: Node

  new val create(
    src_info': SrcInfo,
    children': NodeSeq,
    lhs': Node,
    op': Node,
    rhs': Node)
  =>
    _src_info = src_info'
    _children = children'
    _lhs = lhs'
    _op = op'
    _rhs = rhs'

  fun src_info(): SrcInfo => _src_info

  fun info(): json.Item val =>
    recover
      json.Object([
        ("node", "TypeInfix")
        ("lhs", _lhs.info())
        ("op", _op.info())
        ("rhs", _rhs.info())
      ])
    end

  fun children(): NodeSeq => _children

  fun lhs(): Node => _lhs

  fun op(): Node => _op

  fun rhs(): Node => _rhs
