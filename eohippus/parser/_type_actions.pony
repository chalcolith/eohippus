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
    match _Build.value_or_none(b, rhs)
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
        let value = ast.NodeWith[ast.TypeAtom](
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

    let value = ast.NodeWith[ast.TypeTuple](
      _Build.info(r), c, ast.TypeTuple(types))
    (value, b)

  // fun tag _type_infix(
  //   lhs: Variable,
  //   op: Variable,
  //   rhs: Variable,
  //   r: Success,
  //   c: ast.NodeSeq[ast.Node],
  //   b: Bindings): ((ast.Node | None), Bindings)
  // =>
  //   let lhs' =
  //     try
  //       _Build.value(b, lhs)?
  //     else
  //       return _Build.bind_error(r, c, b, "Type/Infix/LHS")
  //     end
  //   let op' =
  //     try
  //       _Build.value(b, op)?
  //     else
  //       return _Build.bind_error(r, c, b, "Type/Infix/OP")
  //     end
  //   let rhs' =
  //     try
  //       _Build.value(b, rhs)?
  //     else
  //       return _Build.bind_error(r, c, b, "Type/Infix/RHS")
  //     end
  //   (ast.TypeInfix(_Build.info(r), c, lhs', op', rhs'), b)

  // fun tag _type_nominal(
  //   lhs: Variable,
  //   rhs: Variable,
  //   args: Variable,
  //   cap: Variable,
  //   eph: Variable,
  //   r: Success,
  //   c: ast.NodeSeq[ast.Node],
  //   b: Bindings): ((ast.Node | None), Bindings)
  // =>
  //   let lhs' =
  //     try
  //       _Build.value(b, lhs)?
  //     else
  //       return _Build.bind_error(r, c, b, "Type/Nominal/LHS")
  //     end
  //   let rhs' = _Build.value_or_none(b, rhs)
  //   let args' = _Build.value_or_none(b, args)
  //   let cap' = _Build.value_or_none(b, cap)
  //   let eph' = _Build.value_or_none(b, eph)
  //   (ast.TypeNominal(_Build.info(r), c, lhs', rhs', args', cap', eph'), b)

  // fun tag _type_arg(
  //   targ: Variable,
  //   r: Success,
  //   c: ast.NodeSeq[ast.Node],
  //   b: Bindings): ((ast.Node | None), Bindings)
  // =>
  //   let targ' =
  //     try
  //       _Build.value(b, targ)?
  //     else
  //       return _Build.bind_error(r, c, b, "Type/Arg/RHS")
  //     end
  //   (ast.TypeArg(_Build.info(r), c, targ'), b)

  // fun tag _type_param(
  //   name: Variable,
  //   ttype: Variable,
  //   targ: Variable,
  //   r: Success,
  //   c: ast.NodeSeq[ast.Node],
  //   b: Bindings): ((ast.Node | None), Bindings)
  // =>
  //   let name' =
  //     try
  //       _Build.value(b, name)?
  //     else
  //       return _Build.bind_error(r, c, b, "Type/Param/Name")
  //     end
  //   let ttype' = _Build.value_or_none(b, ttype)
  //   let targ' = _Build.value_or_none(b, targ)
  //   (ast.TypeParam(_Build.info(r), c, name', ttype', targ'), b)

  // fun tag _type_params(
  //   r: Success,
  //   c: ast.NodeSeq[ast.Node],
  //   b: Bindings): ((ast.Node | None), Bindings)
  // =>
  //   (ast.TypeParams(_Build.info(r), c), b)

  // fun tag _type_lambda(
  //   bare: Variable,
  //   cap: Variable,
  //   name: Variable,
  //   tparams: Variable,
  //   ptypes: Variable,
  //   rtype: Variable,
  //   partial: Variable,
  //   rcap: Variable,
  //   reph: Variable,
  //   r: Success,
  //   c: ast.NodeSeq[ast.Node],
  //   b: Bindings): ((ast.Node | None), Bindings)
  // =>
  //   let bare' = _Build.value_or_none(b, bare) isnt None
  //   let cap' = _Build.value_or_none(b, cap)
  //   let name' = _Build.value_or_none(b, name)
  //   let tparams' = _Build.values(b, tparams)
  //   let ptypes' = _Build.values(b, ptypes)
  //   let rtype' = _Build.value_or_none(b, rtype)
  //   let partial' = _Build.value_or_none(b, partial) isnt None
  //   let rcap' = _Build.value_or_none(b, rcap)
  //   let reph' = _Build.value_or_none(b, reph)

  //   let lt = ast.TypeLambda(_Build.info(r), c, bare', cap', name', tparams',
  //     ptypes', rtype', partial', rcap', reph')
  //   (lt, b)
