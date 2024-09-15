use "collections"
use "logger"

use ast = "../ast"

class ScopeState
  let node_scope: Scope ref
  var cur_scope: Scope ref

  new create(scope': Scope ref) =>
    node_scope = scope'
    cur_scope = scope'

class ScopeVisitor is ast.Visitor[ScopeState]
  let _log: Logger[String]
  let _node_indices: MapIs[ast.Node, USize] val

  let file_scope: Scope ref
  var _next_index: USize = 0

  new create(
    log: Logger[String],
    canonical_path: String,
    node_indices: MapIs[ast.Node, USize] val)
  =>
    _log = log
    _node_indices = node_indices

    file_scope = Scope(
      FileScope,
      canonical_path,
      canonical_path,
      (0, 0, USize.max_value(), USize.max_value()),
      _next_index = _next_index + 1,
      None)

  fun ref _scope_index(): USize =>
    _next_index = _next_index + 1

  fun _range(node: ast.Node): SrcRange =>
    let si = node.src_info()
    match (si.line, si.column, si.next_line, si.next_column)
    | (let l: USize, let c: USize, let nl: USize, let nc: USize) =>
      (l, c, nl, nc)
    else
      (0, 0, 0, 0)
    end

  fun ref visit_pre(
    parent_state: ScopeState,
    node: ast.Node,
    path: ast.Path,
    errors: Array[ast.TraverseError] iso)
    : (ScopeState, Array[ast.TraverseError] iso^)
  =>
    var scope = parent_state.cur_scope

    scope =
      match node
      | let using: ast.NodeWith[ast.Using] =>
        _handle_using_node(scope, using)
      | let td: ast.NodeWith[ast.Typedef] =>
        _handle_typedef_node(scope, td)
      | let field: ast.NodeWith[ast.TypedefField] =>
        _handle_field_node(scope, field)
      | let method: ast.NodeWith[ast.TypedefMethod] =>
        _handle_method_node(scope, method)
      | let mp: ast.NodeWith[ast.MethodParam] =>
        _handle_method_param_node(scope, mp)
      | let case: ast.NodeWith[ast.MatchCase] =>
        _handle_match_case_node(scope, case)
      | let exp: ast.NodeWith[ast.Expression] =>
        _handle_exp_node(scope, exp)
      | let tp: ast.NodeWith[ast.TuplePattern] =>
        _handle_tuple_pattern_node(scope, tp)
      else
        scope
      end

    (ScopeState(scope), consume errors)

  fun ref _handle_using_node(scope: Scope ref, using: ast.NodeWith[ast.Using])
    : Scope ref
  =>
    match using.data()
    | let using_pony: ast.UsingPony =>
      let identifier =
        match using_pony.identifier
        | let id: ast.NodeWith[ast.Identifier] =>
          scope.add_definition(
            _node_index(id), id.data().string, using.doc_strings())
          id.data().string
        else
          ""
        end
      scope.add_import(
        _node_index(using), identifier, using_pony.path.data().value())
    | let using_ffi: ast.UsingFFI =>
      match using_ffi.identifier
      | let id: ast.NodeWith[ast.Identifier] =>
        scope.add_definition(
          _node_index(id), id.data().string, using.doc_strings())
        id.data().string
      else
        match using_ffi.fun_name
        | let id: ast.NodeWith[ast.Identifier] =>
          scope.add_definition(
            _node_index(id), id.data().string, using.doc_strings())
          id.data().string
        | let ls: ast.NodeWith[ast.LiteralString] =>
          scope.add_definition(
            _node_index(ls), ls.data().value(), using.doc_strings())
          ls.data().value()
        end
      end
    end
    scope

  fun ref _handle_typedef_node(scope: Scope ref, td: ast.NodeWith[ast.Typedef])
    : Scope ref
  =>
    match td.data()
    | let tdc: ast.TypedefClass =>
      let id = tdc.identifier
      scope.add_definition(_node_index(id), id.data().string, td.doc_strings())
      let child = Scope(
        ClassScope,
        id.data().string,
        scope.canonical_path,
        _range(td),
        _scope_index(),
        scope)
      scope.add_child(child)
      child
    | let tdp: ast.TypedefPrimitive =>
      let id = tdp.identifier
      scope.add_definition(_node_index(id), id.data().string, td.doc_strings())
      let child = Scope(
        ClassScope,
        id.data().string,
        scope.canonical_path,
        _range(td),
        _scope_index(),
        scope)
      scope.add_child(child)
      child
    | let tda: ast.TypedefAlias =>
      let id = tda.identifier
      scope.add_definition(_node_index(id), id.data().string, td.doc_strings())
      scope
    end

  fun ref _handle_field_node(
    scope: Scope ref,
    field: ast.NodeWith[ast.TypedefField])
    : Scope ref
  =>
    let id = field.data().identifier
    scope .> add_definition(
      _node_index(id), id.data().string, field.doc_strings())

  fun ref _handle_method_node(
    scope: Scope ref,
    method: ast.NodeWith[ast.TypedefMethod])
    : Scope ref
  =>
    let id = method.data().identifier
    scope.add_definition(_node_index(id), id.data().string, method.doc_strings())
    let child = Scope(
      MethodScope,
      id.data().string,
      scope.canonical_path,
      _range(method),
      _scope_index(),
      scope)
    scope.add_child(child)
    child

  fun ref _handle_method_param_node(
    scope: Scope ref,
    mp: ast.NodeWith[ast.MethodParam])
    : Scope ref
  =>
    let id = mp.data().identifier
    scope .> add_definition(_node_index(id), id.data().string, mp.doc_strings())

  fun ref _handle_match_case_node(
    scope: Scope ref,
    case: ast.NodeWith[ast.MatchCase])
    : Scope ref
  =>
    Scope(
      BlockScope,
      "case",
      scope.canonical_path,
      _range(case),
      _scope_index(),
      scope)

  fun ref _handle_exp_node(scope: Scope ref, exp: ast.NodeWith[ast.Expression])
    : Scope ref
  =>
    match exp.data()
    | let _:
      ( ast.ExpIf
      | ast.ExpRecover
      | ast.ExpTry
      | ast.ExpWhile
      | ast.ExpRepeat
      | ast.ExpFor
      | ast.ExpWith
      | ast.ExpSequence )
    =>
      let child =
        Scope(
          BlockScope,
          exp.name(),
          scope.canonical_path,
          _range(exp),
          _scope_index(),
          scope)
      scope.add_child(child)
      child
    | let _: ast.ExpObject =>
      let child =
        Scope(
          ClassScope,
          "object",
          scope.canonical_path,
          _range(exp),
          _scope_index(),
          scope)
      scope.add_child(child)
      child
    | let decl: ast.ExpDecl =>
      // TODO: make a new current scope in parent
      let id = decl.identifier
      scope .> add_definition(
        _node_index(id), id.data().string, exp.doc_strings())
    else
      scope
    end

  fun ref _handle_tuple_pattern_node(
    scope: Scope ref, tp: ast.NodeWith[ast.TuplePattern])
    : Scope ref
  =>
    for element in tp.data().elements.values() do
      match element
      | let id: ast.NodeWith[ast.Identifier] =>
        scope.add_definition(_node_index(id), id.data().string, [])
      end
    end
    scope

  fun _node_index(node: ast.Node): USize =>
    try
      _node_indices(node)?
    else
      USize.max_value()
    end

  fun ref visit_post(
    node_state: ScopeState,
    node: ast.Node,
    path: ast.Path,
    errors: Array[ast.TraverseError] iso,
    child_states: (ReadSeq[ScopeState] | None),
    new_children: (ast.NodeSeq | None),
    update_map: (ast.ChildUpdateMap | None))
    : (ScopeState, (ast.Node | None), Array[ast.TraverseError] iso^)
  =>
    let new_node = node.clone(where
      new_children' = new_children,
      update_map' = update_map,
      scope_index' = node_state.node_scope.index)
    (node_state, new_node, consume errors)
