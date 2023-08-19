use json = "../json"

class val ExpCall is NodeData
  let lhs: Node
  let args: NodeSeqWith[Sequence]

  new val create(lhs': Node, args': NodeSeqWith[Sequence]) =>
    lhs = lhs'
    args = args'

  fun name(): String => "ExpCall"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("lhs", lhs.get_json()))
    props.push(("args", json_seq(args)))


// class val ExpCall is (Node & NodeWithType[ExpCall] & NodeWithChildren)
//   let _src_info: SrcInfo
//   let _ast_type: (types.AstType | None)
//   let _children: NodeSeq

//   let _lhs: Node
//   let _args_seq: NodeSeq
//   let _args: NodeSeq

//   new val create(src_info': SrcInfo, children': NodeSeq,
//     lhs': Node, args_seq': NodeSeq)
//   =>
//     _src_info = src_info'
//     _ast_type = None
//     _children = children'
//     _lhs = lhs'
//     _args_seq = args_seq'
//     _args =
//       recover val
//         Array[Node].>concat(
//           Iter[Node](_args_seq.values())
//             .filter({(n) =>
//               match n
//               | let _: Trivia => false
//               | let _: Token => false
//               else true end
//             }))
//       end

//   new val _with_ast_type(orig: ExpCall, ast_type': types.AstType) =>
//     _src_info = orig._src_info
//     _ast_type = ast_type'
//     _children = orig._children
//     _lhs = orig._lhs
//     _args_seq = orig._args_seq
//     _args = orig._args

//   fun src_info(): SrcInfo => _src_info

//   fun info(): json.Item val =>
//     let args' = _info_seq(_args)
//     recover
//       json.Object([
//         ("node", "ExpCall")
//         ("lhs", _lhs.info())
//         ("args", args')
//       ])
//     end

//   fun ast_type(): (types.AstType | None) => _ast_type
//   fun val with_ast_type(ast_type': types.AstType): ExpCall =>
//     ExpCall._with_ast_type(this, ast_type')
//   fun children(): NodeSeq => _children

//   fun lhs(): Node => _lhs
//   fun args(): NodeSeq => _args
