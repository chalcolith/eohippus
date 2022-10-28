use "itertools"

use parser = "../parser"
use types = "../types"

class val Call is (Node & NodeWithType[Call] & NodeWithChildren)
  let _src_info: SrcInfo
  let _ast_type: (types.AstType | None)
  let _children: NodeSeq

  let _lhs: Node
  let _param_seq: NodeSeq
  let _params: NodeSeq

  new val create(src_info': SrcInfo, children': NodeSeq,
    lhs': Node, param_seq': NodeSeq)
  =>
    _src_info = src_info'
    _ast_type = None
    _children = children'
    _lhs = lhs'
    _param_seq = param_seq'
    _params =
      recover val
        Array[Node].>concat(
          Iter[Node](_param_seq.values())
            .filter({(n) =>
              match n
              | let _: Trivia => false
              | let _: Token => false
              else true end
            }))
      end

  new val _with_ast_type(orig: Call, ast_type': types.AstType) =>
    _src_info = orig._src_info
    _ast_type = ast_type'
    _children = orig._children
    _lhs = orig._lhs
    _param_seq = orig._param_seq
    _params = orig._params

  fun src_info(): SrcInfo => _src_info
  fun get_string(indent: String): String =>
    recover val
      let str: String ref = String
      let inner: String = indent + "  "
      let inner2: String = indent + "    "
      str.append(indent + "<CALL>\n")
      str.append(inner + "<LHS>\n")
      str.append(_lhs.get_string(inner2))
      str.append("\n")
      str.append(inner + "</LHS>\n")
      str.append(inner + "<PARAMS>\n")
      for param in _params.values() do
        str.append(param.get_string(inner2))
        str.append("\n")
      end
      str.append(inner + "</PARAMS>\n")
      str.append(indent + "</CALL>")
      str
    end
  fun ast_type(): (types.AstType | None) => _ast_type
  fun val with_ast_type(ast_type': types.AstType): Call =>
    Call._with_ast_type(this, ast_type')
  fun children(): NodeSeq => _children

  fun lhs(): Node => _lhs
  fun params(): NodeSeq => _params
