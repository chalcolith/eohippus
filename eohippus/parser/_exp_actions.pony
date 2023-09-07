use "itertools"

use ast = "../ast"

primitive _ExpActions
  fun tag _annotation(
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let ids = _Build.nodes_with[ast.Identifier](c)

    let value = ast.NodeWith[ast.Annotation](
      _Build.info(r), c, ast.Annotation(ids))
    (value, b)

  fun tag _seq(
    ann: Variable,
    body: Variable,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let ann' = _Build.value_with_or_none[ast.Annotation](b, ann, r)
    let expressions = _Build.values_with[ast.Expression](b, body, r)

    let value = ast.NodeWith[ast.Expression](
      _Build.info(r), c, ast.ExpSequence(expressions)
      where annotation' = ann')
    (value, b)

  fun tag _binop(
    lhs: Variable,
    op: Variable,
    rhs: Variable,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let lhs' =
      try
        _Build.value_with[ast.Expression](b, lhs, r)?
      else
        return _Build.bind_error(r, c, b, "Expression/Binop/LHS")
      end
    let op' =
      try
        _Build.value(b, op, r)? as
          (ast.NodeWith[ast.Keyword] | ast.NodeWith[ast.Token])
      else
        return _Build.bind_error(r, c, b, "Expression/Binop/Op")
      end
    let rhs' =
      try
        _Build.value(b, rhs, r)? as
          ( ast.NodeWith[ast.TypeType]
          | ast.NodeWith[ast.Expression]
          | ast.NodeWith[ast.Identifier] )
      else
        return _Build.bind_error(r, c, b, "Expression/Binop/RHS")
      end

    let value = ast.NodeWith[ast.Expression](
      _Build.info(r), c, ast.ExpOperation(lhs', op', rhs'))
    (value, b)

  fun tag _jump(
    keyword: Variable,
    rhs: Variable,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let keyword' =
      try
        _Build.value_with[ast.Keyword](b, keyword, r)?
      else
        return _Build.bind_error(r, c, b, "Expression/Jump/Keyword")
      end
    let rhs' = _Build.value_with_or_none[ast.Expression](b, rhs, r)

    let value = ast.NodeWith[ast.Expression](
      _Build.info(r), c, ast.ExpJump(keyword', rhs'))
    (value, b)

  fun tag _if(
    firstif: Variable,
    elseifs: Variable,
    else_block: Variable,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let firstif' =
      try
        _Build.value_with[ast.IfCondition](b, firstif, r)?
      else
        return _Build.bind_error(r, c, b, "Expression/If/FirstIf")
      end
    let elseifs' = _Build.values_with[ast.IfCondition](b, elseifs, r)
    let conditions =
      recover val
        Array[ast.NodeWith[ast.IfCondition]](1 + elseifs'.size())
          .> push(firstif')
          .> append(elseifs')
      end
    let else_block' = _Build.value_with_or_none[ast.Expression](
      b, else_block, r)

    let value = ast.NodeWith[ast.Expression](
      _Build.info(r), c, ast.ExpIf(ast.IfExp, conditions, else_block'))
    (value, b)

  fun tag _ifcond(
    if_true: Variable,
    then_block: Variable,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let if_true' =
      try
        _Build.value_with[ast.Expression](b, if_true, r)?
      else
        return _Build.bind_error(r, c, b, "Expression/IfCond/Condition")
      end
    let then_block' =
      try
        _Build.value_with[ast.Expression](b, then_block, r)?
      else
        return _Build.bind_error(r, c, b, "Expression/IfCond/TrueSeq")
      end

    let value = ast.NodeWith[ast.IfCondition](
      _Build.info(r), c, ast.IfCondition(if_true', then_block'))
    (value, b)

  fun tag _ifdef(
    firstif: Variable,
    elseifs: Variable,
    else_block: Variable,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let firstif' =
      try
        _Build.value_with[ast.IfCondition](b, firstif, r)?
      else
        return _Build.bind_error(r, c, b, "Expression/If/Firstif")
      end
    let elseifs' = _Build.values_with[ast.IfCondition](b, elseifs, r)
    let conditions =
      recover val
        Array[ast.NodeWith[ast.IfCondition]](1 + elseifs'.size())
          .> push(firstif')
          .> append(elseifs')
      end
    let else_block' = _Build.value_with_or_none[ast.Expression](
      b, else_block, r)

    let value = ast.NodeWith[ast.Expression](
      _Build.info(r), c, ast.ExpIf(ast.IfDef, conditions, else_block'))
    (value, b)

  fun tag _iftype(
    firstif: Variable,
    elseifs: Variable,
    else_block: Variable,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let firstif' =
      try
        _Build.value_with[ast.IfCondition](b, firstif, r)?
      else
        return _Build.bind_error(r, c, b, "Expression/IfType/Firstif")
      end
    let elseifs' = _Build.values_with[ast.IfCondition](b, elseifs, r)
    let conditions =
      recover val
        Array[ast.NodeWith[ast.IfCondition]](1 + elseifs'.size())
          .> push(firstif')
          .> append(elseifs')
      end
    let else_block' = _Build.value_with_or_none[ast.Expression](
      b, else_block, r)

    let value = ast.NodeWith[ast.Expression](
      _Build.info(r), c, ast.ExpIf(ast.IfType, conditions, else_block'))
    (value, b)

  fun tag _iftype_cond(
    if_true: Variable,
    lhs: Variable,
    op: Variable,
    rhs: Variable,
    then_block: Variable,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let cond_children = _Build.values(b, if_true, r)
    let lhs' =
      try
        _Build.value_with[ast.TypeType](b, lhs, r)?
      else
        return _Build.bind_error(r, c, b, "Expression/IfTypeCond/LHS")
      end
    let op' =
      try
        _Build.value_with[ast.Token](b, op, r)?
      else
        return _Build.bind_error(r, c, b, "Expression/IfTypeCond/Op")
      end
    let rhs' =
      try
        _Build.value_with[ast.TypeType](b, rhs, r)?
      else
        return _Build.bind_error(r, c, b, "Expression/IfTypeCond/RHS")
      end
    let then_block' =
      try
        _Build.value_with[ast.Expression](b, then_block, r)?
      else
        return _Build.bind_error(r, c, b, "Expression/IfTypeCond/Then")
      end

    let cond_info = ast.SrcInfo(
      r.data.locator, lhs'.src_info().start, rhs'.src_info().next)
    let cond = ast.NodeWith[ast.Expression](
      cond_info, cond_children, ast.ExpOperation(lhs', op', rhs'))

    let value = ast.NodeWith[ast.IfCondition](
      _Build.info(r), c, ast.IfCondition(cond, then_block'))
    (value, b)

  fun tag _recover(
    cap: Variable,
    body: Variable,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let cap' = _Build.value_with_or_none[ast.Keyword](b, cap, r)
    let body' =
      try
        _Build.value_with[ast.Expression](b, body, r)?
      else
        return _Build.bind_error(r, c, b, "Expression/Recover/Body")
      end

    let value = ast.NodeWith[ast.Expression](
      _Build.info(r), c, ast.ExpRecover(cap', body'))
    (value, b)

  fun tag _prefix(
    op: Variable,
    rhs: Variable,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let op' =
      try
        _Build.value(b, op, r)? as
          (ast.NodeWith[ast.Keyword] | ast.NodeWith[ast.Token])
      else
        return _Build.bind_error(r, c, b, "Expression/Prefix/Op")
      end
    let rhs' =
      try
        _Build.value_with[ast.Expression](b, rhs, r)?
      else
        return _Build.bind_error(r, c, b, "Expression/Prefix/RHS")
      end

    let value = ast.NodeWith[ast.ExpOperation](
      _Build.info(r), c, ast.ExpOperation(None, op', rhs'))
    (value, b)

  fun tag _hash(
    rhs: Variable,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let rhs' =
      try
        _Build.value_with[ast.Expression](b, rhs, r)?
      else
        return _Build.bind_error(r, c, b, "Expression/Hash/RHS")
      end

    let value = ast.NodeWith[ast.ExpHash](
      _Build.info(r), c, ast.ExpHash(rhs'))
    (value, b)

  fun tag _postfix_type_args(
    lhs: Variable,
    args: Variable,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let lhs' =
      try
        _Build.value_with[ast.Expression](b, lhs, r)?
      else
        return _Build.bind_error(r, c, b, "Expression/Postfix/Generic/LHS")
      end
    let args' =
      try
        _Build.value_with[ast.TypeArgs](b, args, r)?
      else
        return _Build.bind_error(r, c, b, "Expression/Postfix/Generic/TypeArgs")
      end

    let value = ast.NodeWith[ast.Expression](
      _Build.info(r), c, ast.ExpGeneric(lhs', args'))
    (value, b)

  fun tag _postfix_call_args(
    lhs: Variable,
    args: Variable,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let lhs' =
      try
        _Build.value_with[ast.Expression](b, lhs, r)?
      else
        return _Build.bind_error(r, c, b, "Expression/Postfix/Call/LHS")
      end
    let args' =
      try
        _Build.value_with[ast.CallArgs](b, args, r)?
      else
        return _Build.bind_error(r, c, b, "Expression/PostFix/Call/CallArgs")
      end

    let value = ast.NodeWith[ast.Expression](
      _Build.info(r), c, ast.ExpCall(lhs', args'))
    (value, b)

  fun tag _call_args(
    pos: Variable,
    named: Variable,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let pos' = _Build.values_with[ast.ExpSequence](b, pos, r)
    let named' = _Build.values_with[ast.ExpOperation](b, named, r)

    let value = ast.NodeWith[ast.CallArgs](
      _Build.info(r), c, ast.CallArgs(pos', named'))
    (value, b)

  fun tag _atom(
    body: Variable,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let body' =
      try
        _Build.value(b, body, r)?
      else
        return _Build.bind_error(r, c, b, "Expression/Atom/Body")
      end

    match body'
    | let exp: ast.NodeWith[ast.Expression] =>
      (exp, b)
    else
      let value = ast.NodeWith[ast.Expression](
        _Build.info(r), c, ast.ExpAtom(body'))
      (value, b)
    end

  fun tag _tuple(
    seqs: Variable,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let seqs' = _Build.values_with[ast.Expression](b, seqs, r)

    let value = ast.NodeWith[ast.Expression](
      _Build.info(r), c, ast.ExpTuple(seqs'))
    (value, b)
