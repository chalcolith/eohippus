use "collections"
use "promises"

use ast = "../ast"
use rules = "rules"

actor Linter
  """
    Provides the ability to lint and fix eoh ASTs.
  """
  let _config: Config
  let _rules: Map[String, Rule]

  new create(config': Config) =>
    _config = config'
    _rules = Map[String, Rule]
    _rules(ConfigKey.trim_trailing_whitespace()) = rules.TrimTrailingWhitespace

  be analyze(node: ast.Node, issues: Promise[ReadSeq[Issue]]) =>
    _LiterImpl(this, node, issues).analyze_next()

actor _LinterImpl
  let _linter: Linter
  let _node: ast.Node
  let _promise: Promise[ReadSeq[Issue]]
  let _iter: Iter[Rule]
  let _issues: Array[Issue]

  new create(
    linter: Linter,
    node: ast.Node,
    promise: Promise[ReadSeq[Issue]])
  =>
    _linter = linter
    _node = node
    _promise = promise
    _iter = _linter._rules.values()
    _issues = Array[Issue]

  be analyze_next() =>
    if _iter.has_next() then
      try
        let rule = _iter.next()?
        rule.analyze(_node, _issues)
        analyze_next()
      end
    else
      _promise(_issues = Array[Issue])
    end
