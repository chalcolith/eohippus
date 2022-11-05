use types = "../types"

class val Sequence is (Node & NodeWithType[Sequence] & NodeWithChildren)
  let _src_info: SrcInfo
  let _ast_type: (types.AstType | None)
  let _children: NodeSeq

  new val create(src_info': SrcInfo, children': NodeSeq) =>
    _src_info = src_info'
    _ast_type = None
    _children = children'

  new val _with_ast_type(orig: Sequence, ast_type': types.AstType) =>
    _src_info = orig._src_info
    _ast_type = ast_type'
    _children = orig._children

  fun src_info(): SrcInfo => _src_info
  fun get_string(indent: String): String =>
    recover val
      let str: String ref = String
      let inner: String = indent + "  "
      str.append(indent + "<SEQUENCE>\n")
      for child in _children.values() do
        str.append(child.get_string(inner))
        str.append("\n")
      end
      str.append(indent + "</SEQUENCE>")
      str
    end
  fun ast_type(): (types.AstType | None) => _ast_type
  fun val with_ast_type(ast_type': types.AstType): Sequence =>
    Sequence._with_ast_type(this, ast_type')
  fun children(): NodeSeq => _children
