use "itertools"

use ast = "../ast"

primitive _TypeActions
  fun tag _type_args(
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let args = _Build.nodes_with[ast.TypeType](c)

    let value = ast.NodeWith[ast.TypeArgs](
      _Build.info(r), c, ast.TypeArgs(args))
    (value, b)

  fun tag _type_params(
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let params = _Build.nodes_with[ast.TypeParam](c)

    let value = ast.NodeWith[ast.TypeParams](
      _Build.info(r), c, ast.TypeParams(params))
    (value, b)

  fun tag _type_param(
    name: Variable,
    ctype: Variable,
    tinit: Variable,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let name' = _Build.value_with_or_none[ast.Identifier](b, name, r)
    let ctype' = _Build.value_with_or_none[ast.TypeType](b, ctype, r)
    let tinit' = _Build.value_with_or_none[ast.TypeType](b, tinit, r)

    let value = ast.NodeWith[ast.TypeParam](
      _Build.info(r), c, ast.TypeParam(name', ctype', tinit'))
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
        _Build.value_with[ast.TypeType](b, lhs, r)?
      else
        return _Build.bind_error(r, c, b, "Type/Arrow/LHS")
      end

    let lhs_string =
      match lhs'.data()
      | let nom: ast.TypeNominal =>
        nom.rhs.data().string
      else
        "lhs?"
      end

    match _Build.value_with_or_none[ast.TypeType](b, rhs, r)
    | let rhs': ast.NodeWith[ast.TypeType] =>
      let rhs_string =
        match rhs'.data()
        | let nom: ast.TypeNominal =>
          nom.rhs.data().string
        else
          "rhs?"
        end

      let value = ast.NodeWith[ast.TypeType](
        _Build.info(r), c, ast.TypeArrow(lhs', rhs'))
      (value, b)
    else
      (lhs', b)
    end

  fun tag _type_atom(
    body: Variable,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    try
      match _Build.value(b, body, r)?
      | let t': ast.NodeWith[ast.TypeType] =>
        (t', b)
      | let node: ast.Node =>
        let value = ast.NodeWith[ast.TypeType](
          _Build.info(r), c, ast.TypeAtom(node))
        (value, b)
      end
    else
      return _Build.bind_error(r, c, b, "Type/Atom/Body")
    end

  fun tag _type_tuple(
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let types = _Build.nodes_with[ast.TypeType](c)

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
    let types' = _Build.values_with[ast.TypeType](b, types, r)
    let op' = _Build.value_with_or_none[ast.Token](b, op, r)

    if types'.size() == 1 then
      try
        return (types'(0)?, b)
      end
    end

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
        _Build.value_with[ast.Identifier](b, lhs, r)?
      else
        return _Build.bind_error(r, c, b, "Type/Nominal/LHS")
      end
    var rhs' = _Build.value_with_or_none[ast.Identifier](b, rhs, r)
    let params' = _Build.value_with_or_none[ast.TypeParams](b, params, r)
    let cap' = _Build.value_with_or_none[ast.Keyword](b, cap, r)
    let eph' = _Build.value_with_or_none[ast.Token](b, eph, r)

    let nominal =
      match rhs'
      | let rhs'': ast.NodeWith[ast.Identifier] =>
        ast.TypeNominal(lhs', rhs'', params', cap', eph')
      else
        ast.TypeNominal(None, lhs', params', cap', eph')
      end
    let value = ast.NodeWith[ast.TypeType](_Build.info(r), c, nominal)
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
    let bare' = _Build.value_with_or_none[ast.Token](b, bare, r) isnt None
    let cap' = _Build.value_with_or_none[ast.Keyword](b, cap, r)
    let name' = _Build.value_with_or_none[ast.Identifier](b, name, r)
    let tparams' = _Build.value_with_or_none[ast.TypeParams](b, tparams, r)
    let ptypes' = _Build.values_with[ast.TypeType](b, ptypes, r)
    let rtype' = _Build.value_with_or_none[ast.TypeType](b, rtype, r)
    let partial' = _Build.value_with_or_none[ast.Token](b, partial, r) isnt None
    let rcap' = _Build.value_with_or_none[ast.Keyword](b, rcap, r)
    let reph' = _Build.value_with_or_none[ast.Token](b, reph, r)

    let value = ast.NodeWith[ast.TypeLambda](
      _Build.info(r),
      c,
      ast.TypeLambda(
        bare', cap', name', tparams', ptypes', rtype', partial', rcap', reph'))
    (value, b)
