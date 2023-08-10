use "itertools"

use json = "../json"

type TypeType is (TypeArrow | TypeTuple | TypeInfix | TypeNominal | TypeLambda)

class val TypeArrow is NodeData
  let lhs: Node
  let rhs: NodeWith[TypeType]

  new val create(lhs': Node, rhs': NodeWith[TypeType]) =>
    lhs = lhs'
    rhs = rhs'

  fun name(): String => "TypeArrow"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("lhs", lhs.get_json()))
    props.push(("rhs", rhs.get_json()))

class val TypeTuple is NodeData
  let types: NodeSeqWith[TypeType]

  new val create(types': NodeSeqWith[TypeType]) =>
    types = types'

  fun name(): String => "TypeTuple"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("types", json_seq[TypeType](types)))

class val TypeInfix is NodeData
  let lhs: NodeWith[TypeType]
  let op: NodeWith[Token]
  let rhs: NodeWith[TypeType]

  new val create(
    lhs': NodeWith[TypeType],
    op': NodeWith[Token],
    rhs': NodeWith[TypeType])
  =>
    lhs = lhs'
    op = op'
    rhs = rhs'

  fun name(): String => "TypeInfix"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("lhs", lhs.get_json()))
    props.push(("op", op.get_json()))
    props.push(("rhs", rhs.get_json()))

class val TypeNominal is NodeData
  let lhs: NodeWith[Identifier]
  let rhs: (NodeWith[Identifier] | None)
  let args: NodeSeqWith[TypeArg]
  let cap: (NodeWith[Keyword] | None)
  let eph: (NodeWith[Token] | None)

  new val create(
    lhs': NodeWith[Identifier],
    rhs': (NodeWith[Identifier] | None),
    args': NodeSeqWith[TypeArg],
    cap': (NodeWith[Keyword] | None),
    eph': (NodeWith[Token] | None))
  =>
    lhs = lhs'
    rhs = rhs'
    args = args'
    cap = cap'
    eph = eph'

  fun name(): String => "TypeNominal"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("lhs", lhs.get_json()))
    match rhs
    | let rhs': NodeWith[Identifier] =>
      props.push(("rhs", rhs'.get_json()))
    end
    if args.size() > 0 then
      props.push(("args", json_seq[TypeArg](args)))
    end
    match cap
    | let cap': NodeWith[Keyword] =>
      props.push(("cap", cap'.get_json()))
    end
    match eph
    | let eph': NodeWith[Token] =>
      props.push(("eph", eph'.get_json()))
    end

class val TypeLambda is NodeData
  let bare: Bool
  let cap: (Node | None)
  let identifier: (NodeWith[Identifier] | None)
  let type_params: NodeSeqWith[TypeParam]
  let param_types: NodeSeqWith[TypeType]
  let return_type: (Node | None)
  let partial: Bool

  new val create(
    bare': Bool,
    cap': (NodeWith[Token] | None),
    identifier': (NodeWith[Identifier] | None),
    type_params': NodeSeqWith[TypeParam],
    param_types': NodeSeqWith[TypeType],
    return_type': (NodeWith[TypeType] | None),
    partial': Bool)
  =>
    bare = bare'
    cap = cap'
    identifier = identifier'
    type_params = type_params'
    param_types = param_types'
    return_type = return_type'
    partial = partial'

  fun name(): String => "TypeLambda"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("bare", bare.string()))
    props.push(("partial", partial.string()))
    match cap
    | let cap': Node =>
      props.push(("cap", cap'.get_json()))
    end
    match identifier
    | let identifier': Node =>
      props.push(("identifier", identifier'.get_json()))
    end
    props.push(("type_params", json_seq[TypeParam](type_params)))
    props.push(("param_types", json_seq[TypeType](param_types)))
    match return_type
    | let return_type': Node =>
      props.push(("return_type", return_type'.get_json()))
    end


// class val TypeType is (Node & NodeWithChildren)
//   let _src_info: SrcInfo
//   let _lhs: Node
//   let _rhs: (Node | None)
//   let _children: NodeSeq

//   new val create(
//     src_info': SrcInfo,
//     children': NodeSeq,
//     lhs': Node,
//     rhs': (Node | None))
//   =>
//     _src_info = src_info'
//     _children = children'
//     _lhs = lhs'
//     _rhs = rhs'

//   fun src_info(): SrcInfo => _src_info

//   fun info(): json.Item val =>
//     recover
//       let items =
//         [ as (String, json.Item):
//           ("node", "TypeArrow")
//           ("lhs", _lhs.info())
//         ]
//       match _rhs
//       | let rhs': Node =>
//         items.push(("rhs", rhs'.info()))
//       end
//       json.Object(items)
//     end

//   fun children(): NodeSeq => _children

//   fun lhs(): Node => _lhs

//   fun rhs(): (Node | None) => _rhs

// class val TypeAtom is (Node & NodeWithChildren)
//   let _src_info: SrcInfo
//   let _children: NodeSeq

//   new val create(src_info': SrcInfo, children': NodeSeq) =>
//     _src_info = src_info'
//     _children = children'

//   fun src_info(): SrcInfo => _src_info

//   fun info(): json.Item val =>
//     recover _info_with_children("TypeAtom") end

//   fun children(): NodeSeq => _children

// class val TypeTuple is (Node & NodeWithChildren)
//   let _src_info: SrcInfo
//   let _children: NodeSeq
//   let _types: NodeSeq[TypeAtom]

//   new val create(src_info': SrcInfo, children': NodeSeq) =>
//     _src_info = src_info'
//     _children = children'
//     _types =
//       recover val
//         Array[TypeAtom].>concat(
//           Iter[Node](_children.values())
//             .filter_map[TypeAtom]({(child) => try child as TypeAtom end }))
//       end

//   fun src_info(): SrcInfo => _src_info

//   fun info(): json.Item val =>
//     let types' = _info_seq[TypeAtom](_types)
//     recover
//       json.Object([
//         ("node", "TypeTuple")
//         ("types", types')
//       ])
//     end

//   fun children(): NodeSeq => _children

//   fun types(): NodeSeq[TypeAtom] => _types

// class val TypeInfix is (Node & NodeWithChildren)
//   let _src_info: SrcInfo
//   let _children: NodeSeq
//   let _lhs: Node
//   let _op: Node
//   let _rhs: Node

//   new val create(
//     src_info': SrcInfo,
//     children': NodeSeq,
//     lhs': Node,
//     op': Node,
//     rhs': Node)
//   =>
//     _src_info = src_info'
//     _children = children'
//     _lhs = lhs'
//     _op = op'
//     _rhs = rhs'

//   fun src_info(): SrcInfo => _src_info

//   fun info(): json.Item val =>
//     recover
//       json.Object([
//         ("node", "TypeInfix")
//         ("lhs", _lhs.info())
//         ("op", _op.info())
//         ("rhs", _rhs.info())
//       ])
//     end

//   fun children(): NodeSeq => _children

//   fun lhs(): Node => _lhs

//   fun op(): Node => _op

//   fun rhs(): Node => _rhs

// class val TypeNominal is (Node & NodeWithChildren)
//   let _src_info: SrcInfo
//   let _children: NodeSeq
//   let _lhs: Node
//   let _rhs: (Node | None)
//   let _args: (Node | None)
//   let _cap: (Node | None)
//   let _eph: (Node | None)

//   new val create(
//     src_info': SrcInfo,
//     children': NodeSeq,
//     lhs': Node,
//     rhs': (Node | None),
//     args': (Node | None),
//     cap': (Node | None),
//     eph': (Node | None))
//   =>
//     _src_info = src_info'
//     _children = children'
//     _lhs = lhs'
//     _rhs = rhs'
//     _args = args'
//     _cap = cap'
//     _eph = eph'

//   fun src_info(): SrcInfo => _src_info

//   fun info(): json.Item val =>
//     recover
//       let items =
//         [ as (String, json.Item):
//           ("node", "TypeNominal")
//           ("lhs", _lhs.info())
//         ]
//       match _rhs
//       | let rhs': Node =>
//         items.push(("rhs", rhs'.info()))
//       end
//       match _args
//       | let args': Node =>
//         items.push(("args", args'.info()))
//       end
//       match _cap
//       | let cap': Node =>
//         items.push(("cap", cap'.info()))
//       end
//       match _eph
//       | let eph': Node =>
//         items.push(("eph", eph'.info()))
//       end
//       json.Object(items)
//     end

//   fun children(): NodeSeq => _children

//   fun lhs(): Node => _lhs

//   fun rhs(): (Node | None) => _rhs

//   fun args(): (Node | None) => _args

//   fun cap(): (Node | None) => _cap

//   fun eph(): (Node | None) => _eph
