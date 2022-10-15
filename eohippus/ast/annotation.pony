use "itertools"

use ".."

class val Annotation is (Node & NodeWithChildren & NodeWithTrivia)
  let _src_info: SrcInfo
  let _children: NodeSeq
  let _body: Span
  let _post_trivia: Trivia

  let _identifiers: NodeSeq[Identifier]

  new val create(src_info': SrcInfo, children': NodeSeq, post_trivia': Trivia)
  =>
    _src_info = src_info'
    _children = children'
    _body = Span(SrcInfo(src_info'.locator(), src_info'.start(),
      post_trivia'.src_info().start()))
    _post_trivia = post_trivia'
    _identifiers =
      recover val
        Array[Identifier].>concat(
          Iter[Node](_children.values())
            .filter_map[Identifier]({(node) => try node as Identifier end }))
      end

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => false
  fun get_string(indent: String): String =>
    recover val
      let str = String
      str.append(indent + "<ANNOTATION ids=\"")
      for id in _identifiers.values() do
        str.append(" " + id.name())
      end
      str.append("\"/>")
      str
    end
  fun children(): NodeSeq => _children
  fun body(): Span => _body
  fun post_trivia(): Trivia => _post_trivia

  fun identifiers(): NodeSeq[Identifier] => _identifiers
