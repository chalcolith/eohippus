use per = "collections/persistent"

use ast = "../ast"

class val Issue
  let rule: Rule
  let start: per.List[ast.Node] "A path from the current (first) node to the root."
  let next: per.List[ast.Node] "A path from the next node to the root."

  new val create(
    rule': Rule,
    start': per.List[ast.Node],
    next': per.List[ast.Node])
  =>
    rule = rule'
    start = start'
    next = next'

  fun val match_start(node: ast.Node): Bool =>
    try
      node is start.head()?
    else
      false
    end

  fun val match_next(node: ast.Node): Bool =>
    try
      node is next.head()?
    else
      false
    end
