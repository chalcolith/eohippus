use per = "collections/persistent"

use ast = "../ast"

class val LintIssue
  start: per.List[ast.Node] "A path from the current (first) node to the root."
  next: per.List[ast.Node] "A path from the next node to the root."
