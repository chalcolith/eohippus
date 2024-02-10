use ast = "../../ast"
use lint = ".."

class val TrimTrailingWhitespace is lint.Rule
  fun message(): String => "trailing whitespace"

  fun analyze(node: ast.Node, issues: Seq[lint.Issue]) =>
    None

  fun fix(node: ast.Node, issues: ReadSeq[lint.Issue]): (ast.Node | None) =>
    None
