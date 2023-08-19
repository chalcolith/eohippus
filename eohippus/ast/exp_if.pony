use json = "../json"

primitive IfExp
primitive IfDef
primitive IfType

type IfKind is (IfExp | IfDef | IfType)

class val ExpIf is NodeData
  let kind: IfKind
  let conditions: NodeSeqWith[IfCondition]
  let else_block: (Node | None)

  new val create(
    kind': IfKind,
    conditions': NodeSeqWith[IfCondition],
    else_block': (Node | None))
  =>
    kind = kind'
    conditions = conditions'
    else_block = else_block'

  fun name(): String => "ExpIf"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    let kind_str =
      match kind
      | IfExp => "IfExp"
      | IfDef => "IfDef"
      | IfType => "IfType"
      end
    props.push(("kind", kind_str))
    props.push(("conditions", Nodes.get_json(conditions)))
    match else_block
    | let block: Node =>
      props.push(("else_block", block.get_json()))
    end

class val IfCondition is NodeData
  let if_true: Node
  let then_block: Node

  new val create(if_true': Node, then_block': Node) =>
    if_true = if_true'
    then_block = then_block'

  fun name(): String => "IfCondition"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("if_true", if_true.get_json()))
    props.push(("then_block", then_block.get_json()))


// class val ExpIf is (Node & NodeWithType[ExpIf] & NodeWithChildren)
//   let _src_info: SrcInfo
//   let _ast_type: (types.AstType | None)
//   let _children: NodeSeq

//   let _conditions: NodeSeq[IfCondition]
//   let _else_block: (Node | None)

//   new val create(src_info': SrcInfo, children': NodeSeq,
//     conditions': NodeSeq[IfCondition], else_block': (Node | None))
//   =>
//     _src_info = src_info'
//     _ast_type = None
//     _children = children'
//     _conditions = conditions'
//     _else_block = else_block'

//   new val _with_ast_type(orig: ExpIf, ast_type': types.AstType) =>
//     _src_info = orig._src_info
//     _ast_type = ast_type'
//     _children = orig._children
//     _conditions = orig._conditions
//     _else_block = orig._else_block

//   fun src_info(): SrcInfo => _src_info

//   fun info(): json.Item val =>
//     recover
//       let conds = _info_seq[IfCondition](_conditions)
//       let properties =
//         [as (String, json.Item):
//           ("node", "ExpIf")
//           ("conditions", conds)
//         ]
//       match _else_block
//       | let n: Node =>
//         properties.push(("else_block", n.info()))
//       end

//       json.Object(properties)
//     end

//   fun ast_type(): (types.AstType | None) => _ast_type
//   fun val with_ast_type(ast_type': types.AstType): ExpIf =>
//     ExpIf._with_ast_type(this, ast_type')
//   fun children(): NodeSeq => _children
//   fun conditions(): NodeSeq[IfCondition] => _conditions
//   fun else_block(): (Node | None) => _else_block

// class val ExpIfDef is (Node & NodeWithType[ExpIfDef] & NodeWithChildren)
//   let _src_info: SrcInfo
//   let _ast_type: (types.AstType | None)
//   let _children: NodeSeq

//   let _conditions: NodeSeq[IfCondition]
//   let _else_block: (Node | None)

//   new val create(src_info': SrcInfo, children': NodeSeq,
//     conditions': NodeSeq[IfCondition], else_block': (Node | None))
//   =>
//     _src_info = src_info'
//     _ast_type = None
//     _children = children'
//     _conditions = conditions'
//     _else_block = else_block'

//   new val _with_ast_type(orig: ExpIfDef, ast_type': types.AstType) =>
//     _src_info = orig._src_info
//     _ast_type = ast_type'
//     _children = orig._children
//     _conditions = orig._conditions
//     _else_block = orig._else_block

//   fun src_info(): SrcInfo => _src_info

//   fun info(): json.Item val =>
//     recover
//       let conds = _info_seq[IfCondition](_conditions)
//       let properties =
//         [as (String, json.Item):
//           ("node", "ExpIfDef")
//           ("conditions", conds)
//         ]
//       match _else_block
//       | let n: Node =>
//         properties.push(("else_block", n.info()))
//       end

//       json.Object(properties)
//     end

//   fun ast_type(): (types.AstType | None) => _ast_type
//   fun val with_ast_type(ast_type': types.AstType): ExpIfDef =>
//     ExpIfDef._with_ast_type(this, ast_type')
//   fun children(): NodeSeq => _children
//   fun conditions(): NodeSeq[IfCondition] => _conditions
//   fun else_block(): (Node | None) => _else_block

// class val ExpIfType is (Node & NodeWithType[ExpIfType] & NodeWithChildren)
//   let _src_info: SrcInfo
//   let _ast_type: (types.AstType | None)
//   let _children: NodeSeq

//   let _conditions: NodeSeq[IfCondition]
//   let _else_block: (Node | None)

//   new val create(src_info': SrcInfo, children': NodeSeq,
//     conditions': NodeSeq[IfCondition], else_block': (Node | None))
//   =>
//     _src_info = src_info'
//     _ast_type = None
//     _children = children'
//     _conditions = conditions'
//     _else_block = else_block'

//   new val _with_ast_type(orig: ExpIfType, ast_type': types.AstType) =>
//     _src_info = orig._src_info
//     _ast_type = ast_type'
//     _children = orig._children
//     _conditions = orig._conditions
//     _else_block = orig._else_block

//   fun src_info(): SrcInfo => _src_info

//   fun info(): json.Item val =>
//     recover
//       let conds = _info_seq[IfCondition](_conditions)
//       let items =
//         [as (String, json.Item):
//           ("node", "ExpIfType")
//           ("conditions", conds)
//         ]
//       match _else_block
//       | let n: Node =>
//         items.push(("else_block", n.info()))
//       end
//       json.Object(items)
//     end

//   fun ast_type(): (types.AstType | None) => _ast_type
//   fun val with_ast_type(ast_type': types.AstType): ExpIfType =>
//     ExpIfType._with_ast_type(this, ast_type')
//   fun children(): NodeSeq => _children
//   fun conditions(): NodeSeq[IfCondition] => _conditions
//   fun else_block(): (Node | None) => _else_block

// class val IfCondition is (Node & NodeWithType[IfCondition] & NodeWithChildren)
//   let _src_info: SrcInfo
//   let _ast_type: (types.AstType | None)
//   let _children: NodeSeq

//   let _if_true: Node
//   let _then_block: Node

//   new val create(src_info': SrcInfo, children': NodeSeq,
//     if_true': Node, then_block': Node) =>
//     _src_info = src_info'
//     _ast_type = None
//     _children = children'
//     _if_true = if_true'
//     _then_block = then_block'

//   new val _with_ast_type(orig: IfCondition, ast_type': types.AstType) =>
//     _src_info = orig._src_info
//     _ast_type = ast_type'
//     _children = orig._children
//     _if_true = orig._if_true
//     _then_block = orig._then_block

//   fun src_info(): SrcInfo => _src_info

//   fun info(): json.Item val =>
//     recover
//       json.Object([
//         ("node", "IfCondition")
//         ("condition", _if_true.info())
//         ("then", _then_block.info())
//       ])
//     end

//   fun ast_type(): (types.AstType | None) => _ast_type
//   fun val with_ast_type(ast_type': types.AstType): IfCondition =>
//     IfCondition._with_ast_type(this, ast_type')
//   fun children(): NodeSeq => _children
//   fun if_true(): Node => _if_true
//   fun then_block(): Node => _then_block
