use "itertools"

use ast = "../ast"

primitive _ExpActions
  fun tag _seq[T: ast.Node val](
    ann: Variable,
    body: Variable,
    body_action: {(Success, ast.NodeSeq[ast.Node]): T} val,
    r: Success,
    c: ast.NodeSeq[ast.Node],
    b: Bindings): ((ast.Node | None), Bindings)
  =>
    (let r', let body') =
      try
        b(body)?
      else
        return _Build.bind_error(r, c, b, "Expression/Sequence/Seq")
      end

    let body_value = body_action(r', body')

    let ann' = _Build.values(b, ann)
    let ids =
      recover val
        Array[ast.Identifier].>concat(Iter[ast.Node](ann'.values())
          .filter_map[ast.Identifier](
            {(n) => try n as ast.Identifier end }))
      end
    if ids.size() > 0 then
      return (ast.Annotation(_Build.info(r), c, ids, body_value), b)
    end
    (body_value, b)

  fun tag _binop(
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
        return _Build.bind_error(r, c, b, "Expression/Assignment/LHS")
      end
    let op' =
      try
        _Build.value(b, op)? as (ast.Keyword | ast.Token)
      else
        return _Build.bind_error(r, c, b, "Expression/Assignment/Op")
      end
    let rhs' =
      try
        _Build.value(b, rhs)?
      else
        return _Build.bind_error(r, c, b, "Expression/Assignment/RHS")
      end
    (ast.ExpOperation(_Build.info(r), c, lhs', op', rhs'), b)

  fun tag _hash(
    rhs: Variable,
    r: Success,
    c: ast.NodeSeq[ast.Node],
    b: Bindings): ((ast.Node | None), Bindings)
  =>
    let rhs' =
      try
        _Build.value(b, rhs)?
      else
        return _Build.bind_error(r, c, b, "Expression/Hash/RHS")
      end
    (ast.ExpHash(_Build.info(r), c, rhs'), b)

  fun tag _if(
    firstif: Variable,
    elseifs: Variable,
    else_block: Variable,
    r: Success,
    c: ast.NodeSeq[ast.Node],
    b: Bindings): ((ast.Node | None), Bindings)
  =>
    let firstif' =
      try
        _Build.value(b, firstif)? as ast.IfCondition
      else
        return _Build.bind_error(r, c, b, "Expression/If/Elsifs")
      end
    let elseifs' =
      recover val
        Array[ast.IfCondition].>concat(
          Iter[ast.Node](_Build.values(b, elseifs).values())
            .filter_map[ast.IfCondition](
              {(n) => try n as ast.IfCondition end }))
      end
    let else_block' = _Build.value_or_none(b, else_block)
    let conditions =
      recover val
        let conditions' = Array[ast.IfCondition](1 + elseifs'.size())
        conditions'.push(firstif')
        conditions'.append(elseifs')
        conditions'
      end

    (ast.ExpIf(_Build.info(r), c, conditions, else_block'), b)

  fun tag _ifdef(
    firstif: Variable,
    elseifs: Variable,
    else_block: Variable,
    r: Success,
    c: ast.NodeSeq[ast.Node],
    b: Bindings): ((ast.Node | None), Bindings)
  =>
    let firstif' =
      try
        _Build.value(b, firstif)? as ast.IfCondition
      else
        return _Build.bind_error(r, c, b, "Expression/If/Firstif")
      end
    let elseifs' =
      recover val
        Array[ast.IfCondition].>concat(
          Iter[ast.Node](_Build.values(b, elseifs).values())
            .filter_map[ast.IfCondition](
              {(n) => try n as ast.IfCondition end }))
      end
    let else_block' = _Build.value_or_none(b, else_block)
    let conditions =
      recover val
        let conditions' = Array[ast.IfCondition](1 + elseifs'.size())
        conditions'.push(firstif')
        conditions'.append(elseifs')
        conditions'
      end

    (ast.ExpIfDef(_Build.info(r), c, conditions, else_block'), b)

  fun tag _iftype(
    firstif: Variable,
    elseifs: Variable,
    else_block: Variable,
    r: Success,
    c: ast.NodeSeq[ast.Node],
    b: Bindings): ((ast.Node | None), Bindings)
  =>
    let firstif' =
      try
        _Build.value(b, firstif)? as ast.IfCondition
      else
        return _Build.bind_error(r, c, b, "Expression/IfType/Firstif")
      end
    let elseifs' =
      recover val
        Array[ast.IfCondition].>concat(
          Iter[ast.Node](_Build.values(b, elseifs).values())
            .filter_map[ast.IfCondition](
              {(n) => try n as ast.IfCondition end }))
      end
    let else_block' = _Build.value_or_none(b, else_block)
    let conditions =
      recover val
        Array[ast.IfCondition](1 + elseifs'.size())
          .>push(firstif')
          .>append(elseifs')
      end

    (ast.ExpIfType(_Build.info(r), c, conditions, else_block'), b)

  fun tag _ifcond(
    if_true: Variable,
    then_block: Variable,
    r: Success,
    c: ast.NodeSeq[ast.Node],
    b: Bindings): ((ast.Node | None), Bindings)
  =>
    let if_true' =
      try
        _Build.value(b, if_true)?
      else
        return _Build.bind_error(r, c, b, "Expression/IfCond/Condition")
      end
    let then_block' =
      try
        _Build.value(b, then_block)?
      else
        return _Build.bind_error(r, c, b, "Expression/IfCond/TrueSeq")
      end
    (ast.IfCondition(_Build.info(r), c, if_true', then_block'), b)

  fun tag _iftype_cond(
    if_true: Variable,
    lhs: Variable,
    op: Variable,
    rhs: Variable,
    then_block: Variable,
    r: Success,
    c: ast.NodeSeq[ast.Node],
    b: Bindings): ((ast.Node | None), Bindings)
  =>
    let cond_children = _Build.values(b, if_true)
    let lhs' =
      try
        _Build.value(b, lhs)?
      else
        return _Build.bind_error(r, c, b, "Expression/IfTypeCond/LHS")
      end
    let op' =
      try
        _Build.value(b, op)? as ast.Token
      else
        return _Build.bind_error(r, c, b, "Expression/IfTypeCond/Op")
      end
    let rhs' =
      try
        _Build.value(b, rhs)?
      else
        return _Build.bind_error(r, c, b, "Expression/IfTypeCond/RHS")
      end
    let then_block' =
      try
        _Build.value(b, then_block)?
      else
        return _Build.bind_error(r, c, b, "Expression/IfTypeCond/Then")
      end
    let cond_info = ast.SrcInfo(
      r.data.locator(), lhs'.src_info().start(), rhs'.src_info().next())
    let cond = ast.ExpOperation(cond_info, cond_children, lhs', op', rhs')

    (ast.IfCondition(_Build.info(r), c, cond, then_block'), b)

  fun tag _prefix(
    op: Variable,
    rhs: Variable,
    r: Success,
    c: ast.NodeSeq[ast.Node],
    b: Bindings): ((ast.Node | None), Bindings)
  =>
    let op' =
      try
        _Build.value(b, op)? as (ast.Keyword | ast.Token)
      else
        return _Build.bind_error(r, c, b, "Expression/Prefix/Op")
      end
    let rhs' =
      try
        _Build.value(b, rhs)?
      else
        return _Build.bind_error(r, c, b, "Expression/Prefix/RHS")
      end
    (ast.ExpOperation(_Build.info(r), c, None, op', rhs'), b)

  fun tag _postfix_type_args(
    lhs: Variable,
    params: Variable,
    r: Success,
    c: ast.NodeSeq[ast.Node],
    b: Bindings): ((ast.Node | None), Bindings)
  =>
    let lhs' =
      try
        _Build.value(b, lhs)?
      else
        return _Build.bind_error(r, c, b, "Expression/Postfix/TParams/LHS")
      end
    let params' =
      try
        _Build.value(b, params)?
      else
        return _Build.bind_error(r, c, b, "Expression/Postfix/TParamsParams")
      end
    (ast.ExpGeneric(_Build.info(r), c, lhs', params'), b)

  fun tag _postfix_call(
    lhs: Variable,
    args: Variable,
    r: Success,
    c: ast.NodeSeq[ast.Node],
    b: Bindings): ((ast.Node | None), Bindings)
  =>
    let lhs' =
      try
        _Build.value(b, lhs)?
      else
        return _Build.bind_error(r, c, b, "Expression/Postfix/Call/LHS")
      end
    let args' = _Build.values(b, args)
    (ast.ExpCall(_Build.info(r), c, lhs', args'), b)

  fun tag _jump(
    keyword: Variable,
    rhs: Variable,
    r: Success,
    c: ast.NodeSeq[ast.Node],
    b: Bindings): ((ast.Node | None), Bindings)
  =>
    let keyword' =
      try
        _Build.value(b, keyword)? as ast.Keyword
      else
        return _Build.bind_error(r, c, b, "Expression/Jump/Keyword")
      end
    let rhs' = try _Build.value(b, rhs)? end
    (ast.ExpJump(_Build.info(r), c, keyword', rhs'), b)
