use "kiuatan"

class val SrcInfo[CH]
  let _locator: String
  let _start: Loc[CH]
  let _next: Loc[CH]

  let _derived_from: (AstNode[CH] | None)

  new val create(locator': String, start': Loc[CH], next': Loc[CH],
    derived_from': (AstNode[CH] | None) = None)
  =>
    _locator = locator'
    _start = start'
    _next = next'
    _derived_from = derived_from'

  new val from_node(src_info: SrcInfo[CH], derived_from': AstNode[CH]) =>
    _locator = src_info._locator
    _start = src_info._start
    _next = src_info._next
    _derived_from = derived_from'

  fun locator() : String => _locator

  fun start(): Loc[CH] => _start
  fun next(): Loc[CH] => _next

  fun derived_from() : (AstNode[CH] | None) =>
    _derived_from
