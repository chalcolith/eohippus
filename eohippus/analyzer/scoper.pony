use "logger"

use ast = "../ast"

interface tag _ScoperNotify
  be scoped_file(task_id: USize, canonical_path: String, scope: Scope iso)
  be scope_failed(
    task_id: USize,
    canonical_path: String,
    errors: ReadSeq[ast.TraverseError] val)

actor Scoper
  let _log: Logger[String]
  let _notify: _ScoperNotify

  new create(log: Logger[String], notify: _ScoperNotify) =>
    _log = log
    _notify = notify

  be scope_syntax_tree(
    task_id: USize,
    canonical_path: String,
    syntax_tree: ast.Node)
  =>
    let scope =
      recover iso
        let visitor = ScopeVisitor(_log, canonical_path, None)
        let state = ScopeState(visitor.file_scope)
        (_, let errors) = ast.SyntaxTree.traverse[ScopeState](
          visitor, state, syntax_tree)
        if errors.size() > 0 then
          _notify.scope_failed(task_id, canonical_path, consume errors)
          return
        end
        visitor.file_scope
      end
    _notify.scoped_file(task_id, canonical_path, consume scope)
