use "kiuatan"
use "../types"

trait val AstNode[CH] is Stringable
  fun src_info(): SrcInfo[CH]

  fun start(): Loc[CH] => src_info().start()
  fun next(): Loc[CH] => src_info().next()

  fun ast_type(): (AstType[CH] | None) => None

  fun eq(other: box->AstNode[CH]): Bool =>
    (this.start() == other.start())
    and (this.next() == other.next())

  fun ne(other: box->AstNode[CH]): Bool =>
    (this.start() != other.start())
    or (this.next() != other.next())

  fun string(): String iso^
