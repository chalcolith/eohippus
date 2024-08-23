use ast = "../ast"

trait val Rule
  fun val name(): String

  fun val message(): String "An informative message for issues found by this rule"

  fun val should_apply(config: Config val): Bool

  fun val analyze(tree: ast.Node, issues: Seq[Issue] iso)
    : (ast.Node, Seq[Issue] iso^, ReadSeq[ast.TraverseError] val)

  fun val fix(tree: ast.Node, issues: ReadSeq[Issue] val)
    : (ast.Node, ReadSeq[Issue] val, ReadSeq[ast.TraverseError] val)
    """
      Returns the result of fixing zero or more of the given issues, plus the
      unfixed issues.
    """
