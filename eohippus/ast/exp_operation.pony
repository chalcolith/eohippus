use json = "../json"

class val ExpOperation is NodeData
  let lhs: (Node | None)
  let op: (NodeWith[Keyword] | NodeWith[Token])
  let rhs: Node

  new val create(
    lhs': (Node | None),
    op': (NodeWith[Keyword] | NodeWith[Token]),
    rhs': Node)
  =>
    lhs = lhs'
    op = op'
    rhs = rhs'

  fun name(): String => "ExpOperation"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    match lhs
    | let lhs': Node =>
      props.push(("lhs", lhs'.get_json()))
    end
    props.push(("op", op.get_json()))
    props.push(("rhs", rhs.get_json()))

// class val ExpOperation is (Node & NodeWithType[ExpOperation] & NodeWithChildren)
//   let _src_info: SrcInfo
//   let _ast_type: (types.AstType | None)
//   let _children: NodeSeq

//   let _lhs: (Node | None)
//   let _op: (Keyword | Token)
//   let _rhs: Node

//   new val create(src_info': SrcInfo, children': NodeSeq,
//     lhs': (Node | None), op': (Keyword | Token), rhs': Node)
//   =>
//     _src_info = src_info'
//     _ast_type = None
//     _children = children'
//     _lhs = lhs'
//     _op = op'
//     _rhs = rhs'

//   new val _with_ast_type(orig: ExpOperation, ast_type': types.AstType) =>
//     _src_info = orig._src_info
//     _ast_type = ast_type'
//     _children = orig._children
//     _lhs = orig._lhs
//     _op = orig._op
//     _rhs = orig._rhs

//   fun src_info(): SrcInfo => _src_info

//   fun info(): json.Item val =>
//     recover
//       let items =
//         [ as (String, json.Item):
//           ("node", "ExpOperation")
//           ("op", _op.info())
//           ("rhs", _rhs.info())
//         ]
//       match _lhs
//       | let lhs': Node =>
//         items.push(("lhs", lhs'.info()))
//       end
//       json.Object(items)
//     end

//   fun ast_type(): (types.AstType | None) => _ast_type

//   fun val with_ast_type(ast_type': types.AstType): ExpOperation =>
//     ExpOperation._with_ast_type(this, ast_type')

//   fun children(): NodeSeq => _children

//   fun lhs(): (Node | None) => _lhs
//   fun op(): (Keyword | Token) => _op
//   fun rhs(): Node => _rhs
