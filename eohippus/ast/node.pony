use parser = "../parser"
use types = "../types"

trait val Node is (Equatable[Node] & Stringable)
  fun src_info(): SrcInfo

  fun start(): parser.Loc => src_info().start()
  fun next(): parser.Loc => src_info().next()

  fun eq(other: box->Node): Bool =>
    if (this.start() != other.start()) or (this.next() != other.next()) then
      return false
    end
    let a = String.concat(this.start().values(this.next()))
    let b = String.concat(other.start().values(other.next()))
    a == b

  fun ne(other: box->Node): Bool => not eq(other)

  fun string(): String iso^

trait val NodeTyped[N: NodeTyped[N]]
  fun ast_type(): (types.AstType | None) => None
  fun val with_ast_type(ast_type': types.AstType): N

trait val NodeValue[V: Equatable[V] #read]
  fun value(): V
