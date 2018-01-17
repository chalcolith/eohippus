
use "kiuatan"

class AstNode[CH]
  let start: ParseLoc[CH] box
  let next: ParseLoc[CH] box

  new create(start': ParseLoc[CH] box, next': ParseLoc[CH] box) =>
    start = start'
    next = next'
