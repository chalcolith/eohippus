use ast = "../ast"

interface tag LinterNotify
  be lint_completed(
    linter: Linter,
    task_id: USize,
    tree: ast.SyntaxTree iso,
    issues: ReadSeq[Issue] val,
    errors: ReadSeq[ast.TraverseError] val)
  =>
    None

  be fix_completed(
    linter: Linter,
    task_id: USize,
    tree: ast.SyntaxTree iso,
    issues: ReadSeq[Issue] val,
    errors: ReadSeq[ast.TraverseError] val)
  =>
    None

  be linter_failed(task_id: USize, message: String) => None
