use json = "../json"

class val ExpGeneric is NodeData
  let lhs: Node
  let args: NodeSeqWith[TypeArg]

  new val create(lhs': Node, args': NodeSeqWith[TypeArg]) =>
    lhs = lhs'
    args = args'

  fun name(): String => "ExpGeneric"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("lhs", lhs.get_json()))
    props.push(("args", Nodes.get_json(args)))

// class val ExpGeneric is (Node & NodeWithType[ExpGeneric] & NodeWithChildren)
//   let _src_info: SrcInfo
//   let _ast_type: (types.AstType | None)
//   let _children: NodeSeq

//   let _lhs: Node
//   let _args: Node

//   new val create(src_info': SrcInfo, children': NodeSeq, lhs': Node,
//     args': Node)
//   =>
//     _src_info = src_info'
//     _ast_type = None
//     _children = children'
//     _lhs = lhs'
//     _args = args'

//   new val _with_ast_type(orig: ExpGeneric, ast_type': types.AstType) =>
//     _src_info = orig._src_info
//     _ast_type = ast_type'
//     _children = orig._children
//     _lhs = orig._lhs
//     _args = orig._args

//   fun src_info(): SrcInfo => _src_info

//   fun info(): json.Item val =>
//     recover
//       let items =
//         [ as (String, json.Item val):
//           ("node", "ExpGeneric")
//           ("lhs", _lhs.info())
//           ("args", _args.info())
//         ]
//       json.Object(items)
//     end

//   fun ast_type(): (types.AstType | None) => _ast_type

//   fun val with_ast_type(ast_type': types.AstType): ExpGeneric =>
//     ExpGeneric._with_ast_type(this, ast_type')

//   fun children(): NodeSeq => _children

//   fun lhs(): Node => _lhs

//   fun args(): Node => _args
