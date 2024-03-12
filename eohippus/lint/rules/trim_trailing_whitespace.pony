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
    : ( ast.SyntaxTree iso^,
        Seq[lint.Issue] iso^,
        ReadSeq[ast.TraverseError] val)
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
    (consume tree, consume issues, recover val Array[ast.TraverseError] end)

  fun val fix(tree: ast.SyntaxTree iso, issues: ReadSeq[lint.Issue] val)
    : ( ast.SyntaxTree iso^,
        ReadSeq[lint.Issue] val,
        ReadSeq[ast.TraverseError] val )
  =>
    var root: ast.Node = tree.root
    let unfixed: Array[lint.Issue] trn = Array[lint.Issue]
    let all_errors: Array[ast.TraverseError] trn = Array[ast.TraverseError]
    for issue in issues.values() do
      if issue.rule.name() == this.name() then
        let visitor = _TrailingWhitespaceVisitor(issue)
        (let new_root, let errors) = tree.traverse[None](consume visitor, root)
        if new_root is root then
          unfixed.push(issue)
        else
          root = new_root
        end
        all_errors.append(errors)
      else
        unfixed.push(issue)
      end
    end

    if root is tree.root then
      (consume tree, consume unfixed, consume all_errors)
    else
      ( recover iso ast.SyntaxTree(root) end,
        consume unfixed,
        consume all_errors )
    end

primitive _TrailingWhitespacePre
primitive _TrailingWhitespacePresent
primitive _TrailingWhitespacePost

type _TrailingWhitespaceState is
  ( _TrailingWhitespacePre
  | _TrailingWhitespacePresent
  | _TrailingWhitespacePost )

class _TrailingWhitespaceVisitor is ast.Visitor[None]
  let _issue: lint.Issue
  var _state: _TrailingWhitespaceState = _TrailingWhitespacePre

  new iso create(issue: lint.Issue) =>
    _issue = issue

  fun ref visit_pre(
    node: ast.Node,
    path: ast.Path,
    errors: Array[ast.TraverseError] iso)
    : (None, Array[ast.TraverseError] iso^)
  =>
    (None, consume errors)

  fun ref visit_post(
    pre_state: None,
    node: ast.Node,
    path: ast.Path,
    errors: Array[ast.TraverseError] iso,
    new_children: (ast.NodeSeq | None) = None)
    : (ast.Node, Array[ast.TraverseError] iso^)
  =>
    // Trailing whitespace will all be children of one node, usually
    // post_trivia (except for pre_trivia in SrcFile)

    let new_children' =
      match new_children
      | let nc: ast.NodeSeq =>
        nc
      else
        return (node, consume errors)
      end

    let node_name = node.name()

    // go through the children and collect the ones that are outside the issue
    var actual_children: (Array[ast.Node] trn | None) = None

    var i: USize = 0
    while i < new_children'.size() do
      let child = try new_children'(i)? else break end

      let child_name = child.name()

      var keep_child = true
      match _state
      | _TrailingWhitespacePre =>
        if _issue.match_start(child) then
          let actual_children' = recover trn Array[ast.Node] end
          var j: USize = 0
          while j < i do
            try actual_children'.push(new_children'(j)?) end
            j = j + 1
          end
          actual_children = consume actual_children'
          keep_child = false
          _state = _TrailingWhitespacePresent
        end
      | _TrailingWhitespacePresent =>
        if _issue.match_next(child) then
          if actual_children is None then
            actual_children = recover trn Array[ast.Node] end
          end
          _state = _TrailingWhitespacePost
        else
          match child
          | let _: ast.NodeWith[ast.Trivia] =>
            keep_child = false
          end
        end
      end

      if keep_child then
        match actual_children
        | let actual_children': Array[ast.Node] trn =>
          actual_children'.push(child)
        end
      end

      i = i + 1
    end

    match actual_children
    | let actual_children': Array[ast.Node] trn =>
      let actual_children'': Array[ast.Node] val = consume actual_children'

      // fix up the pre and post trivia to only include the actual_children
      let actual_pre = node.fix_up[ast.Trivia](
        node.pre_trivia(), actual_children'')
      let actual_post = node.fix_up[ast.Trivia](
        node.post_trivia(), actual_children'')
      let result =
        try
          node.clone(where
            new_children' = actual_children'',
            pre_trivia' = actual_pre,
            post_trivia' = actual_post)?
        else
          errors.push((node, "Error cloning with pruned children"))
          node
        end
      (result, consume errors)
    else
      if new_children' isnt node.children() then
        let result =
          try
            node.clone(where new_children' = new_children')?
          else
            errors.push((node, "Error cloning without pruning"))
            node
          end
        (result, consume errors)
      else
        (node, consume errors)
      end
    end
