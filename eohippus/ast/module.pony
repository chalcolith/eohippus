use parser = "../parser"

class val Module is (Node & NodeParent & NodeTrivia & NodeDocstring)
  let _locator: parser.Locator
  let _src_info: SrcInfo
  let _children: NodeSeq[Node]
  let _trivia: Trivia
  let _docstring: (Docstring | ErrorSection | None)
  let _usings: NodeSeq[Node]
  let _typedefs: NodeSeq[Node]

  new val create(locator': parser.Locator, src_info': SrcInfo,
    children': NodeSeq[Node], trivia': Trivia,
    docstring': (Docstring | ErrorSection | None),
    usings': NodeSeq[Node], typedefs': NodeSeq[Node])
  =>
    _locator = locator'
    _src_info = src_info'
    _children = children'
    _trivia = trivia'
    _docstring = docstring'
    _usings = usings'
    _typedefs = typedefs'

  fun src_info(): SrcInfo => _src_info
  fun string(): String iso^ =>
    "<MODULE " + _locator + ">"

  fun children(): NodeSeq[Node] => _children
  fun trivia(): Trivia => _trivia

  fun docstring(): (Docstring | None) =>
    match _docstring
    | let ds: Docstring => ds
    end

  fun usings(): NodeSeq[Node] => _usings
  fun typedefs(): NodeSeq[Node] => _typedefs
