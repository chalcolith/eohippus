use ast = "../ast"

primitive _TypedefActions
  fun tag _doc_string(
    s: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let s' =
      try
        _Build.value_with[ast.Literal](b, s, r)?
      else
        return _Build.bind_error(d, r, c, b, "DocString/LiteralString")
      end

    let value = ast.NodeWith[ast.DocString](
      _Build.info(d, r), c, ast.DocString(s'))
    (value, b)

  fun tag _method_params(
    params: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let params' = _Build.values_with[ast.MethodParam](b, params, r)

    let value = ast.NodeWith[ast.MethodParams](
      _Build.info(d, r), c, ast.MethodParams(params'))
    (value, b)

  fun tag _method_param(
    identifier: Variable,
    constraint: Variable,
    initializer: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let identifier' =
      try
        _Build.value_with[ast.Identifier](b, identifier, r)?
      else
        return _Build.bind_error(d, r, c, b, "Typedef/MethodParam/Identifier")
      end
    let constraint' = _Build.value_with_or_none[ast.TypeType](b, constraint, r)
    let initializer' =
      _Build.value_with_or_none[ast.Expression](b, initializer, r)

    let value = ast.NodeWith[ast.MethodParam](
      _Build.info(d, r), c, ast.MethodParam(identifier', constraint', initializer'))
    (value, b)

  fun tag _field(
    kind: Variable,
    identifier: Variable,
    constraint: Variable,
    initializer: Variable,
    doc_string: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let kind' =
      try
        _Build.value_with[ast.Keyword](b, kind, r)?
      else
        return _Build.bind_error(d, r, c, b, "Typedef/Field/Kind")
      end
    let identifier' =
      try
        _Build.value_with[ast.Identifier](b, identifier, r)?
      else
        return _Build.bind_error(d, r, c, b, "Typedef/Field/Identifier")
      end
    let constraint' = _Build.value_with_or_none[ast.TypeType](b, constraint, r)
    let initializer' = _Build.value_with_or_none[ast.Expression](b, initializer, r)
    let doc_strings' = _Build.values_with[ast.DocString](b, doc_string, r)

    let value = ast.NodeWith[ast.TypedefField](
      _Build.info(d, r),
      c,
      ast.TypedefField(kind', identifier', constraint', initializer')
      where doc_strings' = doc_strings')
    (value, b)
