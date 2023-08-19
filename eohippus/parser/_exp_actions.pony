use "itertools"

use ast = "../ast"

primitive _ExpActions
  fun tag _annotation(
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let ids =
      recover val
        Array[ast.NodeWith[ast.Identifier]](c.size() - 2) .> concat(
          Iter[ast.Node](c.values())
            .filter_map[ast.NodeWith[ast.Identifier]](
              {(n) => try n as ast.NodeWith[ast.Identifier] end }))
      end

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
    let ann' =
      try
        _Build.value(b, ann)? as ast.NodeWith[ast.Annotation]
      end
    let body' = _Build.values[ast.NodeData](b, body)

    let exps =
      recover val
        Array[ast.Node](body'.size()) .> concat(
          Iter[ast.Node](body'.values())
            .filter(
              {(n) =>
                match n
                | let _: ast.NodeWith[ast.Token] => false
                else true
                end }))
      end

    let value = ast.NodeWith[ast.ExpSequence](
      _Build.info(r), c, ast.ExpSequence(exps)
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
        _Build.value(b, lhs)?
      else
        return _Build.bind_error(r, c, b, "Expression/Binop/LHS")
      end
    let op' =
      try
        _Build.value(b, op)? as
          (ast.NodeWith[ast.Keyword] | ast.NodeWith[ast.Token])
      else
        return _Build.bind_error(r, c, b, "Expression/Binop/Op")
      end
    let rhs' =
      try
        _Build.value(b, rhs)?
      else
        return _Build.bind_error(r, c, b, "Expression/Binop/RHS")
      end

    let value = ast.NodeWith[ast.ExpOperation](
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
        _Build.value(b, keyword)? as ast.NodeWith[ast.Keyword]
      else
        return _Build.bind_error(r, c, b, "Expression/Jump/Keyword")
      end
    let rhs' = try _Build.value(b, rhs)? end

    let value = ast.NodeWith[ast.ExpJump](
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
        _Build.value(b, firstif)? as ast.NodeWith[ast.IfCondition]
      else
        return _Build.bind_error(r, c, b, "Expression/If/FirstIf")
      end
    let elseifs' =
      recover val
        Array[ast.NodeWith[ast.IfCondition]] .> concat(
          Iter[ast.Node](_Build.values(b, elseifs).values())
            .filter_map[ast.NodeWith[ast.IfCondition]](
              {(n) => try n as ast.NodeWith[ast.IfCondition] end }))
      end
    let else_block' = _Build.value_or_none(b, else_block)
    let conditions =
      recover val
        let conditions' = Array[ast.NodeWith[ast.IfCondition]](
          1 + elseifs'.size())
        conditions'.push(firstif')
        conditions'.append(elseifs')
        conditions'
      end

    let value = ast.NodeWith[ast.ExpIf](
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
        _Build.value(b, firstif)? as ast.NodeWith[ast.IfCondition]
      else
        return _Build.bind_error(r, c, b, "Expression/If/Firstif")
      end
    let elseifs' =
      recover val
        Array[ast.NodeWith[ast.IfCondition]] .> concat(
          Iter[ast.Node](_Build.values(b, elseifs).values())
            .filter_map[ast.NodeWith[ast.IfCondition]](
              {(n) => try n as ast.NodeWith[ast.IfCondition] end }))
      end
    let else_block' = _Build.value_or_none(b, else_block)
    let conditions =
      recover val
        Array[ast.NodeWith[ast.IfCondition]](1 + elseifs'.size())
          .> push(firstif')
          .> append(elseifs')
      end

    let value = ast.NodeWith[ast.ExpIf](
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
        _Build.value(b, firstif)? as ast.NodeWith[ast.IfCondition]
      else
        return _Build.bind_error(r, c, b, "Expression/IfType/Firstif")
      end
    let elseifs' =
      recover val
        Array[ast.NodeWith[ast.IfCondition]] .> concat(
          Iter[ast.Node](_Build.values(b, elseifs).values())
            .filter_map[ast.NodeWith[ast.IfCondition]](
              {(n) => try n as ast.NodeWith[ast.IfCondition] end }))
      end
    let else_block' = _Build.value_or_none(b, else_block)
    let conditions =
      recover val
        Array[ast.NodeWith[ast.IfCondition]](1 + elseifs'.size())
          .> push(firstif')
          .> append(elseifs')
      end

    let value = ast.NodeWith[ast.ExpIf](
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
    let cond_children = _Build.values(b, if_true)
    let lhs' =
      try
        _Build.value(b, lhs)?
      else
        return _Build.bind_error(r, c, b, "Expression/IfTypeCond/LHS")
      end
    let op' =
      try
        _Build.value(b, op)? as ast.NodeWith[ast.Token]
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
      r.data.locator, lhs'.src_info().start, rhs'.src_info().next)
    let cond = ast.NodeWith[ast.ExpOperation](
      cond_info, cond_children, ast.ExpOperation(lhs', op', rhs'))

    let value = ast.NodeWith[ast.IfCondition](
      _Build.info(r), c, ast.IfCondition(cond, then_block'))
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
        _Build.value(b, op)? as
          (ast.NodeWith[ast.Keyword] | ast.NodeWith[ast.Token])
      else
        return _Build.bind_error(r, c, b, "Expression/Prefix/Op")
      end
    let rhs' =
      try
        _Build.value(b, rhs)?
      else
        return _Build.bind_error(r, c, b, "Expression/Prefix/RHS")
      end

    let value = ast.NodeWith[ast.ExpOperation](
      _Build.info(r), c, ast.ExpOperation(None, op', rhs'))
    (value, b)



  // fun tag _hash(
  //   rhs: Variable,
  //   r: Success,
  //   c: ast.NodeSeq[ast.Node],
  //   b: Bindings)
  //   : ((ast.Node | None), Bindings)
  // =>
  //   let rhs' =
  //     try
  //       _Build.value(b, rhs)?
  //     else
  //       return _Build.bind_error(r, c, b, "Expression/Hash/RHS")
  //     end
  //   (ast.ExpHash(_Build.info(r), c, rhs'), b)



  // fun tag _postfix_type_args(
  //   lhs: Variable,
  //   params: Variable,
  //   r: Success,
  //   c: ast.NodeSeq[ast.Node],
  //   b: Bindings)
  //   : ((ast.Node | None), Bindings)
  // =>
  //   let lhs' =
  //     try
  //       _Build.value(b, lhs)?
  //     else
  //       return _Build.bind_error(r, c, b, "Expression/Postfix/TParams/LHS")
  //     end
  //   let params' =
  //     try
  //       _Build.value(b, params)?
  //     else
  //       return _Build.bind_error(r, c, b, "Expression/Postfix/TParamsParams")
  //     end
  //   (ast.ExpGeneric(_Build.info(r), c, lhs', params'), b)

  // fun tag _postfix_call(
  //   lhs: Variable,
  //   args: Variable,
  //   r: Success,
  //   c: ast.NodeSeq[ast.Node],
  //   b: Bindings)
  //   : ((ast.Node | None), Bindings)
  // =>
  //   let lhs' =
  //     try
  //       _Build.value(b, lhs)?
  //     else
  //       return _Build.bind_error(r, c, b, "Expression/Postfix/Call/LHS")
  //     end
  //   let args' = _Build.values(b, args)
  //   (ast.ExpCall(_Build.info(r), c, lhs', args'), b)
