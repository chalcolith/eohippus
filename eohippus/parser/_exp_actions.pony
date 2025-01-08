use "itertools"

use ast = "../ast"
use ".."

primitive _ExpActions
  fun tag _annotation(
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let ids = _Build.nodes_with[ast.Identifier](c)
    ast.NodeWith[ast.Annotation](_Build.info(d, r), c, ast.Annotation(ids))

  fun tag _seq(
    ann: Variable,
    body: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let ann' = _Build.value_with_or_none[ast.Annotation](b, ann)
    let expressions = _Build.values_with[ast.Expression](b, body)

    if expressions.size() == 1 then
      try
        let value = ast.NodeWith[ast.Expression].from(expressions(0)?
          where annotation' = ann')
        return value
      end
    end

    ast.NodeWith[ast.Expression](
      _Build.info(d, r), c, ast.ExpSequence(expressions)
      where annotation' = ann')

  fun tag _binop(
    lhs: Variable,
    op: Variable,
    rhs: Variable,
    partial: (Variable | None),
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let lhs' =
      try
        _Build.value(b, lhs)? as
          ( ast.NodeWith[ast.TypeType]
          | ast.NodeWith[ast.Expression]
          | ast.NodeWith[ast.Identifier] )
      end
    let op' =
      try
        _Build.value(b, op)? as
          (ast.NodeWith[ast.Keyword] | ast.NodeWith[ast.Token])
      else
        return _Build.bind_error(d, r, c, b, "Expression/Binop/Op")
      end
    let rhs' =
      try
        _Build.value(b, rhs)? as
          ( ast.NodeWith[ast.TypeType]
          | ast.NodeWith[ast.Expression]
          | ast.NodeWith[ast.Identifier] )
      else
        return _Build.bind_error(d, r, c, b, "Expression/Binop/RHS")
      end
    let partial' =
      match partial
      | let pv: Variable =>
        b.contains(pv)
      else
        false
      end

    ast.NodeWith[ast.Expression](
      _Build.info(d, r), c, ast.ExpOperation(lhs', op', rhs', partial'))

  fun tag _lambda(
    bare: Variable,
    annotation: Variable,
    this_cap: Variable,
    identifier: Variable,
    type_params: Variable,
    params: Variable,
    captures: Variable,
    ret_type: Variable,
    partial: Variable,
    body: Variable,
    ref_cap: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let bare' = b.contains(bare)
    let annotation' =
      _Build.value_with_or_none[ast.Annotation](b, annotation)
    let this_cap' = _Build.value_with_or_none[ast.Keyword](b, this_cap)
    let identifier' =
      _Build.value_with_or_none[ast.Identifier](b, identifier)
    let type_params' =
      _Build.value_with_or_none[ast.TypeParams](b, type_params)
    let params' = _Build.value_with_or_none[ast.MethodParams](b, params)
    let captures' = _Build.value_with_or_none[ast.MethodParams](b, captures)
    let ret_type' = _Build.value_with_or_none[ast.TypeType](b, ret_type)
    let partial' = b.contains(partial)
    let body' =
      try
        _Build.value_with[ast.Expression](b, body)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/Lambda/Body")
      end
    let ref_cap' = _Build.value_with_or_none[ast.Keyword](b, ref_cap)

    ast.NodeWith[ast.Expression](
      _Build.info(d, r), c, ast.ExpLambda(
        bare',
        this_cap',
        identifier',
        type_params',
        params',
        captures',
        ret_type',
        partial',
        body',
        ref_cap')
        where annotation' = annotation')

  fun tag _jump(
    keyword: Variable,
    rhs: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let keyword' =
      try
        _Build.value_with[ast.Keyword](b, keyword)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/Jump/Keyword")
      end
    let rhs' = _Build.value_with_or_none[ast.Expression](b, rhs)

    ast.NodeWith[ast.Expression](
      _Build.info(d, r), c, ast.ExpJump(keyword', rhs'))

  fun tag _if(
    firstif: Variable,
    elseifs: Variable,
    else_block: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let firstif' =
      try
        _Build.value_with[ast.IfCondition](b, firstif)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/If/FirstIf")
      end
    let elseifs' = _Build.values_with[ast.IfCondition](b, elseifs)
    let conditions =
      recover val
        Array[ast.NodeWith[ast.IfCondition]](1 + elseifs'.size())
          .> push(firstif')
          .> append(elseifs')
      end
    let else_block' = _Build.value_with_or_none[ast.Expression](
      b, else_block)

    ast.NodeWith[ast.Expression](
      _Build.info(d, r), c, ast.ExpIf(ast.IfExp, conditions, else_block'))

  fun tag _ifcond(
    if_true: Variable,
    then_block: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let if_true' =
      try
        _Build.value_with[ast.Expression](b, if_true)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/IfCond/Condition")
      end
    let then_block' =
      try
        _Build.value_with[ast.Expression](b, then_block)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/IfCond/TrueSeq")
      end

    ast.NodeWith[ast.IfCondition](
      _Build.info(d, r), c, ast.IfCondition(if_true', then_block'))

  fun tag _ifdef(
    firstif: Variable,
    elseifs: Variable,
    else_block: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let firstif' =
      try
        _Build.value_with[ast.IfCondition](b, firstif)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/If/Firstif")
      end
    let elseifs' = _Build.values_with[ast.IfCondition](b, elseifs)
    let conditions =
      recover val
        Array[ast.NodeWith[ast.IfCondition]](1 + elseifs'.size())
          .> push(firstif')
          .> append(elseifs')
      end
    let else_block' = _Build.value_with_or_none[ast.Expression](
      b, else_block)

    ast.NodeWith[ast.Expression](
      _Build.info(d, r), c, ast.ExpIf(ast.IfDef, conditions, else_block'))

  fun tag _iftype(
    firstif: Variable,
    elseifs: Variable,
    else_block: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let firstif' =
      try
        _Build.value_with[ast.IfCondition](b, firstif)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/IfType/Firstif")
      end
    let elseifs' = _Build.values_with[ast.IfCondition](b, elseifs)
    let conditions =
      recover val
        Array[ast.NodeWith[ast.IfCondition]](1 + elseifs'.size())
          .> push(firstif')
          .> append(elseifs')
      end
    let else_block' = _Build.value_with_or_none[ast.Expression](
      b, else_block)

    ast.NodeWith[ast.Expression](
      _Build.info(d, r), c, ast.ExpIf(ast.IfType, conditions, else_block'))

  fun tag _iftype_cond(
    if_true: Variable,
    lhs: Variable,
    op: Variable,
    rhs: Variable,
    then_block: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let cond_children = _Build.values(b, if_true)
    let lhs' =
      try
        _Build.value_with[ast.TypeType](b, lhs)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/IfTypeCond/LHS")
      end
    let op' =
      try
        _Build.value_with[ast.Token](b, op)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/IfTypeCond/Op")
      end
    let rhs' =
      try
        _Build.value_with[ast.TypeType](b, rhs)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/IfTypeCond/RHS")
      end
    let then_block' =
      try
        _Build.value_with[ast.Expression](b, then_block)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/IfTypeCond/Then")
      end

    let cond_info = ast.SrcInfo(
      d.locator, lhs'.src_info().start, rhs'.src_info().next)
    let cond = ast.NodeWith[ast.Expression](
      cond_info, cond_children, ast.ExpOperation(lhs', op', rhs'))

    ast.NodeWith[ast.IfCondition](
      _Build.info(d, r), c, ast.IfCondition(cond, then_block'))

  fun tag _match(
    exp: Variable,
    cases: Variable,
    else_block: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let exp' =
      try
        _Build.value_with[ast.Expression](b, exp)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/Match/Exp")
      end
    let cases' = _Build.values_with[ast.MatchCase](b, cases)
    let else_block' =
      _Build.value_with_or_none[ast.Expression](b, else_block)

    ast.NodeWith[ast.Expression](
      _Build.info(d, r), c, ast.ExpMatch(exp', cases', else_block'))

  fun tag _match_pattern(
    pattern: Variable,
    condition: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let pattern' =
      try
        _Build.value_with[ast.Expression](b, pattern)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/MatchPattern/Pattern")
      end
    let condition' = _Build.value_with_or_none[ast.Expression](b, condition)

    ast.NodeWith[ast.MatchPattern](
      _Build.info(d, r), c, ast.MatchPattern(pattern', condition'))

  fun tag _match_case(
    patterns: Variable,
    body: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let patterns' = _Build.values_with[ast.MatchPattern](b, patterns)
    let body' =
      try
        _Build.value_with[ast.Expression](b, body)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/MatchCase/Body")
      end

    ast.NodeWith[ast.MatchCase](
      _Build.info(d, r), c, ast.MatchCase(patterns', body'))

  fun tag _while(
    condition: Variable,
    body: Variable,
    else_block: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let condition' =
      try
        _Build.value_with[ast.Expression](b, condition)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/While/Condition")
      end
    let body' =
      try
        _Build.value_with[ast.Expression](b, body)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/While/Body")
      end
    let else_block' = _Build.value_with_or_none[ast.Expression](
      b, else_block)

    ast.NodeWith[ast.Expression](
      _Build.info(d, r), c, ast.ExpWhile(condition', body', else_block'))

  fun tag _repeat(
    body: Variable,
    condition: Variable,
    else_block: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let body' =
      try
        _Build.value_with[ast.Expression](b, body)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/Repeat/Body")
      end
    let condition' =
      try
        _Build.value_with[ast.Expression](b, condition)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/Repeat/Condition")
      end
    let else_block' = _Build.value_with_or_none[ast.Expression](
      b, else_block)

    ast.NodeWith[ast.Expression](
      _Build.info(d, r), c, ast.ExpRepeat(body', condition', else_block'))

  fun tag _for(
    ids: Variable,
    seq: Variable,
    body: Variable,
    else_block: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let ids' =
      try
        _Build.value_with[ast.TuplePattern](b, ids)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/For/Ids")
      end
    let seq' =
      try
        _Build.value_with[ast.Expression](b, seq)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/For/Sequence")
      end
    let body' =
      try
        _Build.value_with[ast.Expression](b, body)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/For/Body")
      end
    let else_block' = _Build.value_with_or_none[ast.Expression](
      b, else_block)

    ast.NodeWith[ast.Expression](
      _Build.info(d, r), c, ast.ExpFor(ids', seq', body', else_block'))

  fun tag _tuple_pattern(
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let elements =
      recover val
        Array[(ast.NodeWith[ast.Identifier] | ast.NodeWith[ast.TuplePattern])]
          .> concat(
            Iter[ast.Node](c.values())
              .filter_map[
                (ast.NodeWith[ast.Identifier]
                | ast.NodeWith[ast.TuplePattern])](
                    {(n) =>
                      match n
                      | let idn: ast.NodeWith[ast.Identifier] =>
                        idn
                      | let tp: ast.NodeWith[ast.TuplePattern] =>
                        tp
                      end
                    }))
      end

    ast.NodeWith[ast.TuplePattern](
      _Build.info(d, r), c, ast.TuplePattern(elements))

  fun tag _with(
    elems: Variable,
    body: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let elems' = _Build.values_with[ast.WithElement](b, elems)
    let body' =
      try
        _Build.value_with[ast.Expression](b, body)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/With/Body")
      end

    ast.NodeWith[ast.Expression](
      _Build.info(d, r), c, ast.ExpWith(elems', body'))

  fun tag _with_elem(
    pattern: Variable,
    body: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let pattern' =
      try
        _Build.value_with[ast.TuplePattern](b, pattern)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/WithElem/Pattern")
      end
    let body' =
      try
        _Build.value_with[ast.Expression](b, body)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/WithElem/Body")
      end

    ast.NodeWith[ast.WithElement](
      _Build.info(d, r), c, ast.WithElement(pattern', body'))

  fun tag _try(
    body: Variable,
    else_block: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let body' = _Build.value_with_or_none[ast.Expression](b, body)
    let else_block' = _Build.value_with_or_none[ast.Expression](
      b, else_block)

    let children =
      match body'
      | None =>
        try
          let c': Array[ast.Node] trn = Array[ast.Node](c.size() + 1)
          let si =
            if c.size() > 0 then
              let first = c(0)?
              c'.push(first)
              ast.SrcInfo(
                d.locator, first.src_info().next, first.src_info().next)
            else
              ast.SrcInfo(d.locator, r.start, r.next)
            end
          c'.push(ast.NodeWith[ast.ErrorSection](
            si, [], ast.ErrorSection(ErrorMsg.expression_block_empty())))
          var i: USize = 1
          while i < c.size() do
            c'.push(c(i)?)
            i = i + 1
          end
          consume c'
        else
          c
        end
      else
        c
      end

    ast.NodeWith[ast.Expression](
      _Build.info(d, r), children, ast.ExpTry(body', else_block'))

  fun tag _recover(
    cap: Variable,
    body: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let cap' = _Build.value_with_or_none[ast.Keyword](b, cap)
    let body' =
      try
        _Build.value_with[ast.Expression](b, body)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/Recover/Body")
      end

    ast.NodeWith[ast.Expression](
      _Build.info(d, r), c, ast.ExpRecover(cap', body'))

  fun tag _consume(
    cap: Variable,
    body: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let cap' = _Build.value_with_or_none[ast.Keyword](b, cap)
    let body' =
      try
        _Build.value_with[ast.Expression](b, body)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/Consume/Body")
      end

    ast.NodeWith[ast.Expression](
      _Build.info(d, r), c, ast.ExpConsume(cap', body'))

  fun tag _decl(
    kind: Variable,
    identifier: Variable,
    decl_type: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let kind' =
      try
        _Build.value_with[ast.Keyword](b, kind)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/Decl/Kind")
      end
    let identifier' =
      try
        _Build.value_with[ast.Identifier](b, identifier)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/Decl/Identifier")
      end
    let decl_type' = _Build.value_with_or_none[ast.TypeType](b, decl_type)

    ast.NodeWith[ast.Expression](
      _Build.info(d, r), c, ast.ExpDecl(kind', identifier', decl_type'))

  fun tag _prefix(
    op: Variable,
    rhs: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let op' =
      try
        _Build.value(b, op)? as
          (ast.NodeWith[ast.Keyword] | ast.NodeWith[ast.Token])
      else
        return _Build.bind_error(d, r, c, b, "Expression/Prefix/Op")
      end
    let rhs' =
      try
        _Build.value_with[ast.Expression](b, rhs)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/Prefix/RHS")
      end

    ast.NodeWith[ast.Expression](
      _Build.info(d, r), c, ast.ExpOperation(None, op', rhs'))

  fun tag _hash(
    rhs: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let rhs' =
      try
        _Build.value_with[ast.Expression](b, rhs)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/Hash/RHS")
      end

    ast.NodeWith[ast.ExpHash](
      _Build.info(d, r), c, ast.ExpHash(rhs'))

  fun tag _postfix_type_args(
    lhs: Variable,
    args: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let lhs' =
      try
        _Build.value_with[ast.Expression](b, lhs)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/Postfix/Generic/LHS")
      end
    let args' =
      try
        _Build.value_with[ast.TypeArgs](b, args)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/Postfix/Generic/TypeArgs")
      end

    ast.NodeWith[ast.Expression](
      _Build.info(d, r), c, ast.ExpGeneric(lhs', args'))

  fun tag _postfix_call_args(
    lhs: Variable,
    args: Variable,
    partial: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let lhs' =
      try
        _Build.value_with[ast.Expression](b, lhs)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/Postfix/Call/LHS")
      end
    let args' =
      try
        _Build.value_with[ast.CallArgs](b, args)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/PostFix/Call/CallArgs")
      end
    let partial' = b.contains(partial)

    ast.NodeWith[ast.Expression](
      _Build.info(d, r), c, ast.ExpCall(lhs', args', partial'))

  fun tag _call_args(
    pos: Variable,
    named: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let pos' = _Build.values_with[ast.Expression](b, pos)
    let named' = _Build.values_with[ast.Expression](b, named)

    ast.NodeWith[ast.CallArgs](
      _Build.info(d, r), c, ast.CallArgs(pos', named'))

  fun tag _atom(
    body: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let body' =
      try
        _Build.value(b, body)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/Atom/Body")
      end

    ast.NodeWith[ast.Expression](
      _Build.info(d, r), c, ast.ExpAtom(body'))

  fun tag _tuple(
    seqs: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let seqs' = _Build.values_with[ast.Expression](b, seqs)

    ast.NodeWith[ast.Expression](
      _Build.info(d, r), c, ast.ExpTuple(seqs'))

  fun tag _array(
    array_type: Variable,
    body: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let array_type' = _Build.value_with_or_none[ast.TypeType](b, array_type)
    let body' = _Build.value_with_or_none[ast.Expression](b, body)

    ast.NodeWith[ast.Expression](
      _Build.info(d, r), c, ast.ExpArray(array_type', body'))

  fun tag _ffi(
    identifier: Variable,
    type_args: Variable,
    call_args: Variable,
    partial: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let identifier' =
      try
        _Build.value(b, identifier)? as
          (ast.NodeWith[ast.Identifier] | ast.NodeWith[ast.LiteralString])
      else
        return _Build.bind_error(d, r, c, b, "Expression/FFI/Identifier")
      end
    let type_args' = _Build.value_with_or_none[ast.TypeArgs](b, type_args)
    let call_args' =
      try
        _Build.value_with[ast.CallArgs](b, call_args)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/FFI/CallArgs")
      end
    let partial' = b.contains(partial)

    ast.NodeWith[ast.Expression](
      _Build.info(d, r),
      c,
      ast.ExpFfi(identifier', type_args', call_args', partial'))

  fun tag _object(
    ann: Variable,
    cap: Variable,
    constraint: Variable,
    members: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let ann' = _Build.value_with_or_none[ast.Annotation](b, ann)
    let cap' = _Build.value_with_or_none[ast.Keyword](b, cap)
    let constraint' = _Build.value_with_or_none[ast.TypeType](b, constraint)
    let members' =
      try
        _Build.value_with[ast.TypedefMembers](b, members)?
      else
        return _Build.bind_error(d, r, c, b, "Expression/Object/Members")
      end

    ast.NodeWith[ast.Expression](
      _Build.info(d, r), c, ast.ExpObject(cap', constraint', members')
      where annotation' = ann')
