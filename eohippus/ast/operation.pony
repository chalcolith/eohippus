use parser = "../parser"
use types = "../types"

class val Operation is (Node & NodeWithType[Operation] & NodeWithChildren)
  let _src_info: SrcInfo
  let _ast_type: (types.AstType | None)
  let _children: NodeSeq

  let _lhs: (Node | None)
  let _op: (Keyword | Token)
  let _rhs: Node

  new val create(src_info': SrcInfo, children': NodeSeq,
    lhs': (Node | None), op': (Keyword | Token), rhs': Node)
  =>
    _src_info = src_info'
    _ast_type = None
    _children = children'
    _lhs = lhs'
    _op = op'
    _rhs = rhs'

  new val _with_ast_type(orig: Operation, ast_type': types.AstType) =>
    _src_info = orig._src_info
    _ast_type = ast_type'
    _children = orig._children
    _lhs = orig._lhs
    _op = orig._op
    _rhs = orig._rhs

  fun src_info(): SrcInfo => _src_info
  fun get_string(indent: String): String =>
    recover val
      let str: String ref = String
      let inner: String = indent + "  "
      str.append(indent + "<OPERATION op=\"" + _op.name() + "\">\n")
      match _lhs
      | let lhs': Node =>
        str.append(lhs'.get_string(inner))
        str.append("\n")
      end
      str.append(_rhs.get_string(inner))
      str.append("\n")
      str.append(indent + "</OPERATION>")
      str
    end
  fun ast_type(): (types.AstType | None) => _ast_type
  fun val with_ast_type(ast_type': types.AstType): Operation =>
    Operation._with_ast_type(this, ast_type')
  fun children(): NodeSeq => _children

  fun lhs(): (Node | None) => _lhs
  fun op(): (Keyword | Token) => _op
  fun rhs(): Node => _rhs
