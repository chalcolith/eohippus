
use "kiuatan"

class val SrcLiteralBool[CH] is SrcNode[CH]
  let _start: Loc[CH]
  let _next: Loc[CH]
  let _value: Bool

  new val create(start': Loc[CH], next': Loc[CH], value': Bool) =>
    _start = start'
    _next = next'
    _value = value'

  fun start(): Loc[CH] => _start
  fun next(): Loc[CH] => _next

  fun string(): String iso^ =>
    _value.string()
