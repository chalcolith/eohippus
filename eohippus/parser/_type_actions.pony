use ast = "../ast"

primitive _TypeActions
  fun tag _type_type(
    lhs: Variable,
    rhs: Variable,
    r: Success,
    c: ast.NodeSeq[ast.Node],
    b: Bindings): ((ast.Node | None), Bindings)
  =>
    let lhs' =
      try
        _Build.value(b, lhs)?
      else
        return _Build.bind_error(r, c, b, "Type/Type/LHS")
      end

    match _Build.value_or_none(b, rhs)
    | let rhs': ast.Node =>
      (ast.TypeArrow(_Build.info(r), c, lhs', rhs'), b)
    else
      (lhs', b)
    end
