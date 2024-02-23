use "collections"
use p = "promises"

use ast = "../ast"
use rules = "rules"

interface Listener
  fun apply(tree: ast.SyntaxTree iso, issues: ReadSeq[Issue] iso)
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

  be analyze(
    tree: ast.SyntaxTree iso,
    listener: Listener val)
  =>
    _LinterImpl(_config, _rules, consume tree, listener)

actor _LinterImpl
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
    _analyze_next(consume tree', Array[Issue])

  be _analyze_next(tree: ast.SyntaxTree iso, issues: Seq[Issue] iso) =>
    if _rules.has_next() then
      try
        let rule = _rules.next()?
        var tree': ast.SyntaxTree iso = consume tree
        var issues': Seq[Issue] iso = consume issues
        if rule.should_apply(_config) then
          (tree', issues') = rule.analyze(consume tree', consume issues')
        end
        _analyze_next(consume tree', consume issues')
      else
        _listener.reject("internal error: overran iterator")
      end
    else
      _listener(consume tree, consume issues)
    end
