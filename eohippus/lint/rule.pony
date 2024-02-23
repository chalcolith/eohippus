use ast = "../ast"

trait val Rule
  fun val name(): String

  fun val message(): String "An informative message for issues found by this rule"

  fun val should_apply(config: Config val): Bool

  fun val analyze(tree: ast.SyntaxTree iso, issues: Seq[Issue] iso)
    : (ast.SyntaxTree iso^, Seq[Issue] iso^)

  fun val fix(orig: ast.Node, issues: ReadSeq[Issue]): (ast.Node | None)
