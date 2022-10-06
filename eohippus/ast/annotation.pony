use "itertools"

use ".."

class val Annotation is (Node & NodeParent)
  let _src_info: SrcInfo
  let _children: NodeSeq

  let _identifiers: NodeSeq[Identifier]

  new val create(src_info': SrcInfo, children': NodeSeq) =>
    _src_info = src_info'
    _children = children'
    _identifiers =
      recover val
        Array[Identifier].>concat(
          Iter[Node](_children.values())
            .filter_map[Identifier]({(node) => try node as Identifier end }))
      end

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => false
  fun children(): NodeSeq => _children
  fun identifiers(): NodeSeq[Identifier] => _identifiers

  fun get_string(indent: String): String =>
    recover val
      let str = String
      str.append(indent + "<ANNOTATION:")
      for id in _identifiers.values() do
        str.append(" " + id.name())
      end
      str.append(">")
      str
    end
