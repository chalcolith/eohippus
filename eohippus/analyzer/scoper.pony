use "collections"
use "files"
use "logger"

use ast = "../ast"

interface tag _ScoperNotify
  be scoped_file(
    task_id: USize,
    canonical_path: FilePath,
    syntax_tree: ast.Node,
    scope: Scope val)
  be scope_failed(
    task_id: USize,
    canonical_path: FilePath,
    errors: ReadSeq[ast.TraverseError] val)

actor Scoper
  let _log: Logger[String]
  let _notify: _ScoperNotify

  new create(log: Logger[String], notify: _ScoperNotify) =>
    _log = log
    _notify = notify

  be scope_syntax_tree(
    task_id: USize,
    canonical_path: FilePath,
    syntax_tree: ast.Node,
    node_indices: MapIs[ast.Node, USize] val)
  =>
    (let scoped_tree, let file_scope) =
      recover val
        let visitor = ScopeVisitor(_log, canonical_path, node_indices)
        let state = ScopeState(visitor.file_scope)
        (let tree, let errors) =
          ast.SyntaxTree.traverse[ScopeState ref](visitor, state, syntax_tree)
        if errors.size() > 0 then
          _notify.scope_failed(task_id, canonical_path, consume errors)
          return
        end
        (_, _, let nl, let nc) = visitor.file_scope.get_child_range()
        visitor.file_scope.range =
          ( visitor.file_scope.range._1
          , visitor.file_scope.range._2
          , nl
          , nc )
        (tree, visitor.file_scope)
      end
    _notify.scoped_file(task_id, canonical_path, scoped_tree, file_scope)
