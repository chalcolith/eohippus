use "collections"
use p = "promises"

use ast = "../ast"
use rules = "rules"

interface Listener
  fun apply(
    tree: ast.SyntaxTree iso,
    issues: ReadSeq[Issue] val,
    errors: ReadSeq[ast.TraverseError] val)
  fun reject(message: String)

actor Linter
  """
    Provides the ability to lint and fix eoh ASTs.
  """
  let _config: Config val
  let _rules: Map[String, Rule] val

  new create(config': Config val) =>
    _config = config'
    _rules =
      recover val
        Map[String, Rule]
          .> update(
            ConfigKey.trim_trailing_whitespace(), rules.TrimTrailingWhitespace)
      end

  be analyze(tree: ast.SyntaxTree iso, listener: Listener val) =>
    _Analyze(_config, _rules, consume tree, listener)

  be fix(
    tree: ast.SyntaxTree iso,
    issues: ReadSeq[Issue] val,
    listener: Listener val)
  =>
    _Fix(_config, _rules, consume tree, issues, listener)

actor _Analyze
  let _config: Config val
  let _rules: Iterator[Rule]
  let _listener: Listener val

  new create(
    config': Config val,
    rules': Map[String, Rule] val,
    tree': ast.SyntaxTree iso,
    listener': Listener val)
  =>
    _config = config'
    _rules = rules'.values()
    _listener = listener'
    _analyze_next(consume tree', Array[Issue], Array[ast.TraverseError])

  be _analyze_next(
    tree: ast.SyntaxTree iso,
    issues: Seq[Issue] iso,
    errors: Seq[ast.TraverseError] iso)
  =>
    if _rules.has_next() then
      try
        let rule = _rules.next()?
        var tree': ast.SyntaxTree iso = consume tree
        var issues': Seq[Issue] iso = consume issues
        if rule.should_apply(_config) then
          (tree', issues', let errors') = rule.analyze(
            consume tree', consume issues')
          errors.append(errors')
        end
        _analyze_next(consume tree', consume issues', consume errors)
      else
        _listener.reject("internal error: analyze overran iterator")
      end
    else
      _listener(consume tree, consume issues, consume errors)
    end

actor _Fix
  let _config: Config val
  let _rules: Iterator[Rule]
  let _listener: Listener val

  new create(
    config': Config val,
    rules': Map[String, Rule] val,
    tree': ast.SyntaxTree iso,
    issues': ReadSeq[Issue] val,
    listener': Listener val)
  =>
    _config = config'
    _rules = rules'.values()
    _listener = listener'
    _fix_next(consume tree', issues', Array[ast.TraverseError])

  be _fix_next(
    tree: ast.SyntaxTree iso,
    issues: ReadSeq[Issue] val,
    errors: Seq[ast.TraverseError] iso)
  =>
    if _rules.has_next() then
      try
        let rule = _rules.next()?
        var tree': ast.SyntaxTree iso = consume tree
        var issues' = issues
        if rule.should_apply(_config) then
          (tree', issues', let errors') = rule.fix(consume tree', issues')
          errors.append(errors')
        end
        _fix_next(consume tree', consume issues', consume errors)
      else
        _listener.reject("internal error: fix overran iterator")
      end
    else
      _listener(consume tree, consume issues, consume errors)
    end
