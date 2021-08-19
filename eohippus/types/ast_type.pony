use "../ast"

trait val AstType[CH] is Stringable
  fun val name(): String
  fun val full_name(): String
  fun val node(): AstNode[CH]

  fun string(): String iso^
