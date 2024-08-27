use "collections"
use "logger"

use ast = "../ast"

interface tag _ScoperNotify
  be scoped_file(
    task_id: USize,
    canonical_path: String,
    syntax_tree: ast.Node,
    scope: Scope val)
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
    (let scope, let node_scopes) =
      recover val
        let visitor = ScopeVisitor(_log, canonical_path)
        let state = ScopeState(visitor.file_scope)
        (_, let errors) =
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
        (visitor.file_scope, visitor.node_scopes)
      end

    let val_scopes = MapIs[Scope tag, Scope val]
    _get_val_scopes(scope, val_scopes)

    let scoped_tree = _assign_scopes(syntax_tree, node_scopes, val_scopes)
    _notify.scoped_file(task_id, canonical_path, scoped_tree, scope)

  fun tag _get_val_scopes(
    scope: Scope val,
    val_scopes: MapIs[Scope tag, Scope val])
  =>
    val_scopes(scope) = scope
    for child in scope.children.values() do
      _get_val_scopes(child, val_scopes)
    end

  fun tag _assign_scopes(
    node: ast.Node,
    node_scopes: MapIs[ast.Node, Scope tag] val,
    val_scopes: MapIs[Scope tag, Scope])
    : ast.Node
  =>
    let scope =
      try
        val_scopes(node_scopes(node)?)?
      end

    if node.children().size() > 0 then
      let new_children: Array[ast.Node] trn =
        Array[ast.Node](node.children().size())
      let update_map: ast.ChildUpdateMap trn = ast.ChildUpdateMap
      for old_child in node.children().values() do
        let new_child = _assign_scopes(old_child, node_scopes, val_scopes)
        update_map(old_child) = new_child
        new_children.push(new_child)
      end
      node.clone(where
        scope' = scope,
        new_children' = consume new_children,
        update_map' = consume update_map)
    elseif scope isnt None then
      node.clone(where scope' = scope)
    else
      node
    end
