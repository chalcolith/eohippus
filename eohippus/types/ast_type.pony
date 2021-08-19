use ast = "../ast"

trait val AstType is Stringable
  fun val name(): String
  fun val full_name(): String

  fun val node(): ast.Node

  fun string(): String iso^
