use "itertools"

use json = "../json"
use types = "../types"

class val Sequence is NodeData
  new create() =>
    None

  fun name(): String => "Sequence"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    None

// class val Sequence is (Node & NodeWithType[Sequence] & NodeWithChildren)
//   let _src_info: SrcInfo
//   let _ast_type: (types.AstType | None)
//   let _children: NodeSeq

//   new val create(src_info': SrcInfo, children': NodeSeq) =>
//     _src_info = src_info'
//     _ast_type = None
//     _children = children'

//   new val _with_ast_type(orig: Sequence, ast_type': types.AstType) =>
//     _src_info = orig._src_info
//     _ast_type = ast_type'
//     _children = orig._children

//   fun src_info(): SrcInfo => _src_info

//   fun info(): json.Item val =>
//     recover
//       let children' = _info_seq(_children)
//       json.Object([
//         ("node", "Sequence")
//         ("children", children')
//       ])
//     end

//   fun ast_type(): (types.AstType | None) => _ast_type

//   fun val with_ast_type(ast_type': types.AstType): Sequence =>
//     Sequence._with_ast_type(this, ast_type')

//   fun children(): NodeSeq => _children
