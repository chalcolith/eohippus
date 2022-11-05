use "itertools"
use types = "../types"
use ".."

class val Annotation is (Node & NodeWithType[Annotation] & NodeWithChildren)
  let _src_info: SrcInfo
  let _ast_type: (types.AstType | None)
  let _children: NodeSeq

  let _identifiers: NodeSeq[Identifier]
  let _body: Node

  new val create(src_info': SrcInfo, children': NodeSeq,
    identifiers': NodeSeq[Identifier], body': Node)
  =>
    _src_info = src_info'
    _ast_type = None
    _children = children'
    _identifiers = identifiers'
    _body = body'

  new val _with_ast_type(orig: Annotation, ast_type': types.AstType) =>
    _src_info = orig._src_info
    _ast_type = ast_type'
    _children = orig._children
    _identifiers = orig._identifiers
    _body = orig._body

  fun src_info(): SrcInfo => _src_info
  fun get_string(indent: String): String =>
    recover val
      let str = String
      let inner: String = indent + "  "
      str.append(indent + "<ANNOTATION ids=\"")
      for id in _identifiers.values() do
        str.append(" " + id.name())
      end
      str.append("\">\n")
      str.append(_body.get_string(inner))
      str.append("\n")
      str.append(indent + "</ANNOTATION>")
      str
    end
  fun ast_type(): (types.AstType | None) => _ast_type
  fun val with_ast_type(ast_type': types.AstType): Annotation =>
    Annotation._with_ast_type(this, ast_type')
  fun children(): NodeSeq => _children

  fun identifiers(): NodeSeq[Identifier] => _identifiers
  fun body(): Node => _body
