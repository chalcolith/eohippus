use parser = "../parser"
use types = "../types"

type NodeSeq[N: Node] is ReadSeq[N] val

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

trait val NodeTyped[N: NodeTyped[N]] is Node
  fun ast_type(): (types.AstType | None)
  fun val with_ast_type(ast_type': types.AstType): N

trait val NodeValued[V: Equatable[V] #read] is Node
  fun value(): V
  fun value_error(): Bool

trait val NodeParent is Node
  fun children(): NodeSeq[Node]

trait val NodeTrivia is Node
  fun trivia(): Trivia

trait val NodeDocstring is Node
  fun docstring(): (Docstring | None)
