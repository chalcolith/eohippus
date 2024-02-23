use per = "collections/persistent"

use ast = "../../ast"
use lint = ".."

class val TrimTrailingWhitespace is lint.Rule
  fun val name(): String => lint.ConfigKey.trim_trailing_whitespace()

  fun val message(): String => "trailing whitespace"

  fun val should_apply(config: lint.Config val): Bool =>
    try
      config(lint.ConfigKey.trim_trailing_whitespace())?.lower() == "true"
    else
      false
    end

  fun val analyze(tree: ast.SyntaxTree iso, issues: Seq[lint.Issue] iso)
    : (ast.SyntaxTree iso^, Seq[lint.Issue] iso^)
  =>
    let ws_seen = Array[ast.Path]
    let rule = this
    let issues' = Array[lint.Issue]
    let fn =
      object
        fun ref apply(node: ast.Node, path: ast.Path) =>
          if node.children().size() == 0 then
            match node
            | let t: ast.NodeWith[ast.Trivia] if
              (t.data().kind is ast.EndOfLineTrivia) or
              (t.data().kind is ast.EndOfFileTrivia)
            =>
              if ws_seen.size() > 0 then
                try issues'.push(lint.Issue(rule, ws_seen(0)?, path)) end
              end
              ws_seen.clear()
            | let t: ast.NodeWith[ast.Trivia] if
              t.data().kind is ast.WhiteSpaceTrivia
            =>
              ws_seen.push(path)
            else
              ws_seen.clear()
            end
          else
            for child in node.children().values() do
              this(child, path.prepend(child))
            end
          end
        end
    fn(tree.root, per.Cons[ast.Node](tree.root, per.Nil[ast.Node]))
    for issue in issues'.values() do
      issues.push(issue)
    end
    (consume tree, consume issues)

  fun val fix(node: ast.Node, issues: ReadSeq[lint.Issue]): (ast.Node | None) =>
    None
