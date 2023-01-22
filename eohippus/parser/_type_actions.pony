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

    let rhs' = _Build.value_or_none(b, rhs)
    (ast.TypeType(_Build.info(r), c, lhs', rhs'), b)

  fun tag _type_infix(
    lhs: Variable,
    op: Variable,
    rhs: Variable,
    r: Success,
    c: ast.NodeSeq[ast.Node],
    b: Bindings): ((ast.Node | None), Bindings)
  =>
    let lhs' =
      try
        _Build.value(b, lhs)?
      else
        return _Build.bind_error(r, c, b, "Type/Infix/LHS")
      end
    let op' =
      try
        _Build.value(b, op)?
      else
        return _Build.bind_error(r, c, b, "Type/Infix/OP")
      end
    let rhs' =
      try
        _Build.value(b, rhs)?
      else
        return _Build.bind_error(r, c, b, "Type/Infix/RHS")
      end
    (ast.TypeInfix(_Build.info(r), c, lhs', op', rhs'), b)
