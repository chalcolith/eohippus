use "itertools"

use json = "../json"
use parser = "../parser"
use types = "../types"

class val TypeParams is (Node & NodeWithChildren)
  let _src_info: SrcInfo
  let _children: NodeSeq

  let _params: NodeSeq[TypeParam]

  new val create(src_info': SrcInfo, children': NodeSeq) =>
    _src_info = src_info'
    _children = children'
    _params =
      recover val
        Array[TypeParam].>concat(
          Iter[Node](_children.values())
            .filter_map[TypeParam]({(n) => try n as TypeParam end }))
      end

  fun src_info(): SrcInfo => _src_info

  fun info(): json.Item val =>
    recover
      let items =
        [ as (String, json.Item val):
          ("node", "TypeParams")
        ]
      let params' = _info_seq(_params)
      if params'.size() > 0 then
        items.push(("params", params'))
      end
      json.Object(items)
    end

  fun children(): NodeSeq => _children

  fun params(): NodeSeq[TypeParam] => _params

class val TypeParam is (Node & NodeWithChildren)
  let _src_info: SrcInfo
  let _children: NodeSeq

  let _name: Node
  let _type: (Node | None)
  let _arg: (Node | None)

  new val create(src_info': SrcInfo, children': NodeSeq, name': Node,
    type_type': (Node | None), arg': (Node | None))
  =>
    _src_info = src_info'
    _children = children'
    _name = name'
    _type = type_type'
    _arg = arg'

  fun src_info(): SrcInfo => _src_info

  fun info(): json.Item val =>
    recover
      let items =
        [ as (String, json.Item val):
          ("node", "TypeParam")
          ("name", _name.info())
        ]
      match _type
      | let type': Node =>
        items.push(("type", type'.info()))
      end
      match _arg
      | let arg': Node =>
        items.push(("arg", arg'.info()))
      end
      json.Object(items)
    end

  fun children(): NodeSeq => _children

  fun name(): Node => _name

  fun param_type(): (Node | None) => _type

  fun arg(): (Node | None) => _arg
