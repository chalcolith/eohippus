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

  fun val analyze(tree: ast.Node, issues: Seq[lint.Issue] iso)
    : (ast.Node, Seq[lint.Issue] iso^, ReadSeq[ast.TraverseError] val)
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
    fn(tree, per.Cons[ast.Node](tree, per.Nil[ast.Node]))
    for issue in issues'.values() do
      issues.push(issue)
    end
    (tree, consume issues, [])

  fun val fix(tree: ast.Node, issues: ReadSeq[lint.Issue] val)
    : (ast.Node, ReadSeq[lint.Issue] val, ReadSeq[ast.TraverseError] val)
  =>
    var root: ast.Node = tree
    let unfixed: Array[lint.Issue] trn = Array[lint.Issue]
    let all_errors: Array[ast.TraverseError] trn = Array[ast.TraverseError]
    for issue in issues.values() do
      if issue.rule.name() == this.name() then
        let visitor = _TrailingWhitespaceVisitor(issue)
        (let new_root, let errors) =
          ast.SyntaxTree.traverse[None](consume visitor, None, root)
        if new_root is root then
          unfixed.push(issue)
          all_errors.push((root, "tree was unchanged by " + this.name()))
        else
          root = new_root
        end
        all_errors.append(errors)
      else
        unfixed.push(issue)
      end
    end

    if root is tree then
      (tree, consume unfixed, consume all_errors)
    else
      (root, _, let errors) = ast.SyntaxTree.add_line_info(root)
      for err in errors.values() do
        all_errors.push(err)
      end
      (root, consume unfixed, consume all_errors)
    end

class _TrailingWhitespaceVisitor is ast.Visitor[None]
  let _issue: lint.Issue

  var _in_trailing_ws: Bool = false

  new iso create(issue: lint.Issue) =>
    _issue = issue

  fun ref visit_pre(
    parent_state: None,
    node: ast.Node,
    path: ast.Path,
    errors: Array[ast.TraverseError] iso)
    : (None, Array[ast.TraverseError] iso^)
  =>
    (None, consume errors)

  fun ref visit_post(
    parent_state: None,
    node_state: None,
    node: ast.Node,
    path: ast.Path,
    errors: Array[ast.TraverseError] iso,
    new_children: (ast.NodeSeq | None) = None,
    update_map: (ast.ChildUpdateMap | None) = None)
    : (None, (ast.Node | None), Array[ast.TraverseError] iso^)
  =>
    // check for trailing whitespace
    if _issue.match_start(node) then
      _in_trailing_ws = true
    end
    if _issue.match_next(node) then
      _in_trailing_ws = false
    end

    // if we're a leaf and in trailing whitespace, delete us
    if _in_trailing_ws then
      match node
      | let t: ast.NodeWith[ast.Trivia] if
          (t.data().kind is ast.WhiteSpaceTrivia)
      =>
        return (None, None, consume errors)
      end
    end

    // if our children have been adjusted, clone us with the new children
    let new_node =
      match (new_children, update_map)
      | (let nc: ast.NodeSeq, let um: ast.ChildUpdateMap) =>
        node.clone(where new_children' = nc, update_map' = um)
      else
        node
      end
    (None, new_node, consume errors)
