use parser = "../parser"
use types = "../types"

trait val Node is (Equatable[Node] & Stringable)
  fun src_info(): SrcInfo

  fun start(): parser.Loc => src_info().start()
  fun next(): parser.Loc => src_info().next()

  fun eq(other: box->Node): Bool =>
    (this.start() == other.start()) and (this.next() == other.next())

  fun ne(other: box->Node): Bool =>
    (this.start() != other.start()) or (this.next() != other.next())

  fun string(): String iso^

trait val NodeTyped[N: NodeTyped[N]]
  fun ast_type(): (types.AstType | None) => None
  fun val with_ast_type(ast_type': types.AstType): N

trait val NodeValue[V: Equatable[V] #read]
  fun value(): V
