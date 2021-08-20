use parser = "../parser"

primitive Inherited
primitive Reified
primitive Desugared

type SrcDerivation is (Inherited | Reified | Desugared)

class val SrcInfo
  let _locator: String
  let _start: parser.Loc
  let _next: parser.Loc

  let _derived_from: ((SrcDerivation, Node) | None)

  new val create(locator': String, start': parser.Loc, next': parser.Loc,
    derived_from': ((SrcDerivation, Node)  | None) = None)
  =>
    _locator = locator'
    _start = start'
    _next = next'
    _derived_from = derived_from'

  new val from_node(src_info: SrcInfo, derived_from': (SrcDerivation, Node)) =>
    _locator = src_info._locator
    _start = src_info._start
    _next = src_info._next
    _derived_from = derived_from'

  fun locator() : String => _locator

  fun start(): parser.Loc => _start
  fun next(): parser.Loc => _next

  fun derived_from() : ((SrcDerivation, Node) | None) =>
    _derived_from
