
use "collections"
use "kiuatan"

type AstNode[CH: (Unsigned & Integer[CH])] is
  (
    ( AstNodeLiteralBool[CH] val
    )
    & AstNodeSpan[CH] val
  )


trait AstNodeSpan[CH: (Unsigned & Integer[CH])]
  fun children(): Array[AstNode[CH] val] val

  fun start(): ParseLoc[CH] val ? => children()(0)?.start()

  fun next(): ParseLoc[CH] val ? =>
    let ch = children()
    ch(ch.size()-1)?.next()

  fun ast_type(): (AstType[CH] val | None)
