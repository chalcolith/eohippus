use "logger"

use ast = "../ast"

class ScopeState
  let current_scope: Scope

  new create(current_scope': Scope) =>
    current_scope = current_scope'

class ScopeVisitor is ast.Visitor[ScopeState]
  let _log: Logger[String]
  let file_scope: Scope

  new create(
    log: Logger[String],
    canonical_path: String,
    parent: (Scope | None))
  =>
    _log = log
    file_scope = Scope(FileScope, canonical_path, parent)

  fun ref visit_pre(
    parent_state: ScopeState,
    node: ast.Node,
    path: ast.Path,
    errors: Array[ast.TraverseError] iso)
    : (ScopeState, Array[ast.TraverseError] iso^)
  =>
    var scope = parent_state.current_scope

    if scope.kind is QualifierScope then
      scope = Scope(BlockScope, "", scope)
    end

    match node
    | let td: ast.NodeWith[ast.Typedef] =>
      (let identifier, let need_new) =
        match td.data()
        | let tdc: ast.TypedefClass =>
          (tdc.identifier.data().string, true)
        | let tdp: ast.TypedefPrimitive =>
          (tdp.identifier.data().string, true)
        | let tda: ast.TypedefAlias =>
          (tda.identifier.data().string, false)
        end
      let si = td.src_info()
      scope.add_definition(identifier, si, td.doc_strings())

      if need_new then
        let new_scope = Scope(ClassScope, identifier, scope)
        return (ScopeState(new_scope), consume errors)
      end
    | let meth: ast.NodeWith[ast.TypedefMethod] =>
      let identifier = meth.data().identifier.data().string
      let new_scope = Scope(MethodScope, identifier, scope)
      return (ScopeState(new_scope), consume errors)
    | let exp: ast.NodeWith[ast.Expression] =>
      match exp.data()
      | let _:
        ( ast.ExpIf
        | ast.ExpRecover
        | ast.ExpTry
        | ast.ExpWhile
        | ast.ExpRepeat
        | ast.ExpFor
        | ast.ExpWith )
      =>
        let new_scope = Scope(BlockScope, "", scope)
        return (ScopeState(new_scope), consume errors)
      | let _: ast.ExpObject =>
        let new_scope = Scope(ClassScope, "", scope)
        return (ScopeState(new_scope), consume errors)
      | let decl: ast.ExpDecl =>
        let identifier = decl.identifier.data().string
        scope.add_definition(identifier, exp.src_info(), exp.doc_strings())
        let new_scope = Scope(BlockScope, identifier, scope)
        let new_state = ScopeState(new_scope)
        return (new_state, consume errors)
      | let op: ast.ExpOperation =>
        match op.op
        | let token: ast.NodeWith[ast.Token]
          if token.data().string == ast.Tokens.dot()
        =>
          let new_scope = Scope(QualifierScope, "", scope)
          let new_state = ScopeState(new_scope)
          return (new_state, consume errors)
        end
      end
    | let case: ast.NodeWith[ast.MatchCase] =>
      let new_scope = Scope(BlockScope, "", scope)
      return (ScopeState(new_scope), consume errors)
    | let mp: ast.NodeWith[ast.MethodParam] =>
      let identifier = mp.data().identifier.data().string
      scope.add_definition(identifier, mp.src_info(), mp.doc_strings())
    | let tp: ast.NodeWith[ast.TuplePattern] =>
      for element in tp.data().elements.values() do
        match element
        | let id: ast.NodeWith[ast.Identifier] =>
          let identifier = id.data().string
          scope.add_definition(identifier, id.src_info(), id.doc_strings())
        end
      end
    | let id: ast.NodeWith[ast.Identifier] =>
      let identifier = id.data().string
      scope.add_content(
        identifier,
        id.src_info(),
        id.doc_strings())
    end

    let new_state = ScopeState(scope)
    (new_state, consume errors)

  fun ref visit_post(
    parent_state: ScopeState,
    node_state: ScopeState,
    node: ast.Node,
    path: ast.Path,
    errors: Array[ast.TraverseError] iso,
    new_children: (ast.NodeSeq | None),
    update_map: (ast.ChildUpdateMap | None))
    : (ScopeState, (ast.Node | None), Array[ast.TraverseError] iso^)
  =>
    (parent_state, node, consume errors)
