use "itertools"

use json = "../json"
use parser = "../parser"

class val SrcFile is
  (Node & NodeWithChildren & NodeWithTrivia & NodeWithDocstring)
  let _src_info: SrcInfo
  let _children: NodeSeq
  let _body: Span
  let _pre_trivia: Trivia
  let _post_trivia: Trivia
  let _docstring: NodeSeq[Docstring]

  let _usings: NodeSeq
  let _typedefs: NodeSeq

  new val create(src_info': SrcInfo, children': NodeSeq,
    pre_trivia': Trivia, docstring': NodeSeq[Docstring],
    usings': NodeSeq, typedefs': NodeSeq)
  =>
    _src_info = src_info'
    _children = children'
    _body = Span(SrcInfo(src_info'.locator(), pre_trivia'.src_info().next(),
      src_info'.next()))
    _pre_trivia = pre_trivia'
    _post_trivia = Trivia(
      SrcInfo(src_info'.locator(), src_info'.next(), src_info'.next()), [])
    _docstring = docstring'
    _usings = usings'
    _typedefs = typedefs'

  fun src_info(): SrcInfo => _src_info

  fun info(): json.Item iso^ =>
    recover
      let items = Array[(String, json.Item)].>push(("node", "SrcFile"))

      let docstrings' =
        recover val
          Array[json.Item].>concat(
            Iter[Docstring](_docstring.values())
              .map[json.Item]({(ds) => ds.info()}))
        end
      if docstrings'.size() > 0 then
        items.push(("docstrings", json.Sequence(docstrings')))
      end

      let usings' =
        recover val
          Array[json.Item].>concat(
            Iter[Node](_usings.values())
              .map[json.Item]({(us) => us.info()}))
        end
      if usings'.size() > 0 then
        items.push(("usings", json.Sequence(usings')))
      end

      let typedefs' =
        recover val
          Array[json.Item].>concat(
            Iter[Node](_typedefs.values())
              .map[json.Item]({(td) => td.info()}))
        end
      if typedefs'.size() > 0 then
        items.push(("typedefs", json.Sequence(typedefs')))
      end

      json.Object(items)
    end

  fun children(): NodeSeq => _children
  fun body(): Span => _body
  fun pre_trivia(): Trivia => _pre_trivia
  fun post_trivia(): Trivia => _post_trivia
  fun docstring(): NodeSeq[Docstring] => _docstring

  fun usings(): NodeSeq => _usings
  fun typedefs(): NodeSeq => _typedefs
