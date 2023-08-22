use "itertools"

use ast = "../ast"

primitive _TypeActions
  fun tag _type_args(
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let args = _Build.children[ast.TypeType](c)

    let value = ast.NodeWith[ast.TypeArgs](
      _Build.info(r), c, ast.TypeArgs(args))
    (value, b)

  fun tag _type_params(
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let params = _Build.children[ast.TypeParam](c)

    let value = ast.NodeWith[ast.TypeParams](
      _Build.info(r), c, ast.TypeParams(params))
    (value, b)

  fun tag _type_param(
    name: Variable,
    ttype: Variable,
    tinit: Variable,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let name' =
      try
        _Build.value(b, name)? as ast.NodeWith[ast.Identifier]
      else
        return _Build.bind_error(r, c, b, "Type/Param/Name")
      end
    let ttype' = _Build.value_or_none[ast.TypeType](b, ttype)
    let tinit' = _Build.value_or_none[ast.TypeType](b, tinit)

    let value = ast.NodeWith[ast.TypeParam](
      _Build.info(r), c, ast.TypeParam(name', ttype', tinit'))
    (value, b)

  fun tag _type_arrow(
    lhs: Variable,
    rhs: Variable,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let lhs' =
      try
        _Build.value(b, lhs)? as ast.NodeWith[ast.TypeType]
      else
        return _Build.bind_error(r, c, b, "Type/Arrow/LHS")
      end
    match _Build.value_or_none[ast.TypeType](b, rhs)
    | let rhs': ast.NodeWith[ast.TypeType] =>
      let value = ast.NodeWith[ast.TypeType](
        _Build.info(r), c, ast.TypeArrow(lhs', rhs'))
      (value, b)
    else
      (lhs', b)
    end

  fun tag _type_atom(
    child: Variable,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    try
      match _Build.value(b, child)?
      | let t': ast.NodeWith[ast.TypeType] =>
        (t', b)
      | let n': ast.Node =>
        let value = ast.NodeWith[ast.TypeType](
          _Build.info(r), c, ast.TypeAtom(n'))
        (value, b)
      end
    else
      return _Build.bind_error(r, c, b, "Type/Atom/Child")
    end

  fun tag _type_tuple(
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let types = _Build.children[ast.TypeType](c)

    let value = ast.NodeWith[ast.TypeType](
      _Build.info(r), c, ast.TypeTuple(types))
    (value, b)

  fun tag _type_infix(
    types: Variable,
    op: Variable,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let types' = _Build.values[ast.TypeType](b, types)
    let op' = _Build.value_or_none[ast.Token](b, op)

    let value = ast.NodeWith[ast.TypeType](
      _Build.info(r), c, ast.TypeInfix(types', op'))
    (value, b)

  fun tag _type_nominal(
    lhs: Variable,
    rhs: Variable,
    params: Variable,
    cap: Variable,
    eph: Variable,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let lhs' =
      try
        _Build.value(b, lhs)? as ast.NodeWith[ast.Identifier]
      else
        return _Build.bind_error(r, c, b, "Type/Nominal/LHS")
      end
    let rhs' = _Build.value_or_none[ast.Identifier](b, rhs)
    let params' = _Build.value_or_none[ast.TypeParams](b, params)
    let cap' = _Build.value_or_none[ast.Keyword](b, cap)
    let eph' = _Build.value_or_none[ast.Token](b, eph)

    let value = ast.NodeWith[ast.TypeType](
      _Build.info(r), c, ast.TypeNominal(lhs', rhs', params', cap', eph'))
    (value, b)

  fun tag _type_lambda(
    bare: Variable,
    cap: Variable,
    name: Variable,
    tparams: Variable,
    ptypes: Variable,
    rtype: Variable,
    partial: Variable,
    rcap: Variable,
    reph: Variable,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let bare' = _Build.value_or_none[ast.Token](b, bare) isnt None
    let cap' = _Build.value_or_none[ast.Keyword](b, cap)
    let name' = _Build.value_or_none[ast.Identifier](b, name)
    let tparams' = _Build.value_or_none[ast.TypeParams](b, tparams)
    let ptypes' = _Build.values[ast.TypeType](b, ptypes)
    let rtype' = _Build.value_or_none[ast.TypeType](b, rtype)
    let partial' = _Build.value_or_none[ast.Token](b, partial) isnt None
    let rcap' = _Build.value_or_none[ast.Keyword](b, rcap)
    let reph' = _Build.value_or_none[ast.Token](b, reph)

    let value = ast.NodeWith[ast.TypeLambda](
      _Build.info(r),
      c,
      ast.TypeLambda(
        bare', cap', name', tparams', ptypes', rtype', partial', rcap', reph'))
    (value, b)
