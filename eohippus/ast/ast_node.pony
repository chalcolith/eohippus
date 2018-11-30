
use "kiuatan"

trait box AstNode[CH] is Stringable
  fun start(): Loc[CH]
  fun next(): Loc[CH]

  fun string(): String iso^


class EOFNode[CH] is AstNode[CH]
  let _start: Loc[CH]
  let _next: Loc[CH]

  new create(start': Loc[CH], next': Loc[CH]) =>
    _start = start'
    _next = next'

  fun start(): Loc[CH] => _start
  fun next(): Loc[CH] => _next

  fun string(): String iso^ =>
    "<EOF>"
