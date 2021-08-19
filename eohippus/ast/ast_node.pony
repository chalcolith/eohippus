use "kiuatan"
use "../types"

trait val AstNode[CH] is (Equatable[AstNode[CH]] & Stringable)
  fun src_info(): SrcInfo[CH]

  fun start(): Loc[CH] => src_info().start()
  fun next(): Loc[CH] => src_info().next()

  fun eq(other: box->AstNode[CH]): Bool =>
    (this.start() == other.start()) and (this.next() == other.next())

  fun ne(other: box->AstNode[CH]): Bool =>
    (this.start() != other.start()) or (this.next() != other.next())

  fun string(): String iso^

trait val AstNodeTyped[CH, Node: AstNodeTyped[CH, Node]]
  fun ast_type(): (AstType[CH] | None) => None
  fun val with_ast_type(ast_type': AstType[CH]): Node

trait val AstNodeValue[V: Equatable[V] #read]
  fun value(): V
