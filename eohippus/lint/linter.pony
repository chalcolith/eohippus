
use config = "../config"
use ast = "../ast"

class Linter
  """
    Provides the ability to lint and fix eoh ASTs.
  """
  let _config: config.LintConfig

  new create(config': config.LintConfig) =>
    _config = config'

  fun find_issues(ast.SyntaxTree): ReadSeq[LintIssue] =>
