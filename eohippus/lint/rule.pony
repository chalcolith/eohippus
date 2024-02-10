use ast = "../ast"

trait val Rule
  fun message(): String "An informative message for issues found by this rule"

  fun analyze(node: ast.Node, issues: Seq[Issue])

  fun fix(orig: ast.Node, issues: ReadSeq[Issue]): (ast.Node | None)
