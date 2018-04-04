
use "collections"
use "kiuatan"

class AstNodeLiteralBool[CH: (Unsigned & Integer[CH])] is AstNodeSpan[CH]
  let _start: ParseLoc[CH] val
  let _next: ParseLoc[CH] val
  let _ast_type: (AstType[CH] val | None)
  let _value: Bool

  new create(start': ParseLoc[CH] val, next': ParseLoc[CH] val,
    value': Bool, ast_type': (AstType[CH] val | None) = None)
  =>
    _start = start'.clone()
    _next = next'.clone()
    _value = value'
    _ast_type = ast_type'

  fun children(): Array[AstNode[CH] val] val =>
    recover Array[AstNode[CH] val] end

  fun start(): ParseLoc[CH] val => _start
  fun next(): ParseLoc[CH] val => _next
  fun ast_type(): (AstType[CH] val | None) => _ast_type

  fun value(): Bool => _value
