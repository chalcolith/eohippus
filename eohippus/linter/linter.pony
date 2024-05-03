use "collections"
use p = "promises"

use ast = "../ast"
use rules = "rules"

interface tag LinterListener
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

actor Linter
  """
    Provides the ability to lint and fix eohippus ASTs.
  """
  let _listener: LinterListener
  let _config: Config val
  let _rules: Map[String, Rule] val

  new create(config': Config val, listener': LinterListener) =>
    _config = config'
    _listener = listener'
    _rules =
      recover val
        Map[String, Rule]
          .> update(
            ConfigKey.trim_trailing_whitespace(), rules.TrimTrailingWhitespace)
      end

  be lint(
    task_id: USize,
    tree: ast.SyntaxTree iso)
  =>
    _Lint(this, task_id, _config, _rules, consume tree, _listener)

  be fix(
    task_id: USize,
    tree: ast.SyntaxTree iso,
    issues: ReadSeq[Issue] val)
  =>
    _Fix(this, task_id, _config, _rules, consume tree, issues, _listener)

actor _Lint
  let _linter: Linter
  let _task_id: USize
  let _config: Config val
  let _rules: Iterator[Rule]
  let _listener: LinterListener

  new create(
    linter': Linter,
    task_id': USize,
    config': Config val,
    rules': Map[String, Rule] val,
    tree': ast.SyntaxTree iso,
    listener': LinterListener)
  =>
    _linter = linter'
    _task_id = task_id'
    _config = config'
    _rules = rules'.values()
    _listener = listener'
    _lint_next(consume tree', Array[Issue], Array[ast.TraverseError])

  be _lint_next(
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
        _lint_next(consume tree', consume issues', consume errors)
      else
        _listener.linter_failed(
          _task_id, "internal error: analyze overran iterator")
      end
    else
      _listener.lint_completed(
        _linter, _task_id, consume tree, consume issues, consume errors)
    end

actor _Fix
  let _linter: Linter
  let _task_id: USize
  let _config: Config val
  let _rules: Iterator[Rule]
  let _listener: LinterListener

  new create(
    linter': Linter,
    task_id': USize,
    config': Config val,
    rules': Map[String, Rule] val,
    tree': ast.SyntaxTree iso,
    issues': ReadSeq[Issue] val,
    listener': LinterListener)
  =>
    _linter = linter'
    _task_id = task_id'
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
        _listener.linter_failed(
          _task_id, "internal error: fix overran iterator")
      end
    else
      _listener.fix_completed(
        _linter, _task_id, consume tree, consume issues, consume errors)
    end
