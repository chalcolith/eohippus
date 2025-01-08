use "itertools"

use ast = "../ast"

primitive _TypeActions
  fun tag _type_args(
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let args = _Build.nodes_with[ast.TypeType](c)

    ast.NodeWith[ast.TypeArgs](
      _Build.info(d, r), c, ast.TypeArgs(args))

  fun tag _type_params(
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let params = _Build.nodes_with[ast.TypeParam](c)

    ast.NodeWith[ast.TypeParams](
      _Build.info(d, r), c, ast.TypeParams(params))

  fun tag _type_param(
    name: Variable,
    ctype: Variable,
    tinit: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let name' = _Build.value_with_or_none[ast.Identifier](b, name)
    let ctype' = _Build.value_with_or_none[ast.TypeType](b, ctype)
    let tinit' = _Build.value_with_or_none[ast.TypeType](b, tinit)

    ast.NodeWith[ast.TypeParam](
      _Build.info(d, r), c, ast.TypeParam(name', ctype', tinit'))

  fun tag _type_arrow(
    lhs: Variable,
    rhs: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let lhs' =
      try
        _Build.value_with[ast.TypeType](b, lhs)?
      else
        return _Build.bind_error(d, r, c, b, "Type/Arrow/LHS")
      end

    let lhs_string =
      match lhs'.data()
      | let nom: ast.TypeNominal =>
        nom.rhs.data().string
      else
        "lhs?"
      end

    match _Build.value_with_or_none[ast.TypeType](b, rhs)
    | let rhs': ast.NodeWith[ast.TypeType] =>
      let rhs_string =
        match rhs'.data()
        | let nom: ast.TypeNominal =>
          nom.rhs.data().string
        else
          "rhs?"
        end

      ast.NodeWith[ast.TypeType](
        _Build.info(d, r), c, ast.TypeArrow(lhs', rhs'))
    else
      lhs'
    end

  fun tag _type_atom(
    body: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    try
      match _Build.value(b, body)?
      | let t': ast.NodeWith[ast.TypeType] =>
        t'
      | let node: ast.Node =>
        ast.NodeWith[ast.TypeType](
          _Build.info(d, r), c, ast.TypeAtom(node))
      end
    else
      return _Build.bind_error(d, r, c, b, "Type/Atom/Body")
    end

  fun tag _type_tuple(
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let types = _Build.nodes_with[ast.TypeType](c)

    ast.NodeWith[ast.TypeType](
      _Build.info(d, r), c, ast.TypeTuple(types))

  fun tag _type_infix(
    types: Variable,
    op: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let types' = _Build.values_with[ast.TypeType](b, types)
    let op' = _Build.value_with_or_none[ast.Token](b, op)

    if types'.size() == 1 then
      try
        return types'(0)?
      end
    end

    ast.NodeWith[ast.TypeType](
      _Build.info(d, r), c, ast.TypeInfix(types', op'))

  fun tag _type_nominal(
    lhs: Variable,
    rhs: Variable,
    params: Variable,
    cap: Variable,
    eph: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let lhs' =
      try
        _Build.value_with[ast.Identifier](b, lhs)?
      else
        return _Build.bind_error(d, r, c, b, "Type/Nominal/LHS")
      end
    var rhs' = _Build.value_with_or_none[ast.Identifier](b, rhs)
    let params' = _Build.value_with_or_none[ast.TypeParams](b, params)
    let cap' = _Build.value_with_or_none[ast.Keyword](b, cap)
    let eph' = _Build.value_with_or_none[ast.Token](b, eph)

    let nominal =
      match rhs'
      | let rhs'': ast.NodeWith[ast.Identifier] =>
        ast.TypeNominal(lhs', rhs'', params', cap', eph')
      else
        ast.TypeNominal(None, lhs', params', cap', eph')
      end
    ast.NodeWith[ast.TypeType](_Build.info(d, r), c, nominal)

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
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let bare' = _Build.value_with_or_none[ast.Token](b, bare) isnt None
    let cap' = _Build.value_with_or_none[ast.Keyword](b, cap)
    let name' = _Build.value_with_or_none[ast.Identifier](b, name)
    let tparams' = _Build.value_with_or_none[ast.TypeParams](b, tparams)
    let ptypes' = _Build.values_with[ast.TypeType](b, ptypes)
    let rtype' = _Build.value_with_or_none[ast.TypeType](b, rtype)
    let partial' = _Build.value_with_or_none[ast.Token](b, partial) isnt None
    let rcap' = _Build.value_with_or_none[ast.Keyword](b, rcap)
    let reph' = _Build.value_with_or_none[ast.Token](b, reph)

    ast.NodeWith[ast.TypeType](
      _Build.info(d, r),
      c,
      ast.TypeLambda(
        bare', cap', name', tparams', ptypes', rtype', partial', rcap', reph'))
