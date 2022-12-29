use "itertools"

use ast = "../ast"

class ExpressionBuilder
  let _context: Context
  let _trivia: TriviaBuilder
  let _token: TokenBuilder
  let _keyword: KeywordBuilder
  let _operator: OperatorBuilder
  let _literal: LiteralBuilder
  let _type: TypeBuilder

  var _identifier: (NamedRule | None) = None
  var _annotation: (NamedRule | None) = None
  var _exp_seq: (NamedRule | None) = None
  var _exp_item: (NamedRule | None) = None

  new create(
    context: Context,
    trivia: TriviaBuilder,
    token: TokenBuilder,
    keyword: KeywordBuilder,
    operator: OperatorBuilder,
    literal: LiteralBuilder,
    type_builder: TypeBuilder)
  =>
    _context = context
    _trivia = trivia
    _token = token
    _keyword = keyword
    _operator = operator
    _literal = literal
    _type = type_builder

  fun ref identifier(): NamedRule =>
    match _identifier
    | let r: NamedRule => r
    else
      let trivia = _trivia.trivia()
      let id_chars: String = _Letters.with_underscore() + _Digits() + "'"

      let identifier' =
        recover val
          NamedRule("Identifier",
            _Build.with_post[ast.Trivia](
              recover
                Disj([
                  Conj([
                    Single(ast.Tokens.underscore())
                    Star(Single(id_chars))
                  ])
                  Conj([
                    Single(_Letters())
                    Star(Single(id_chars))
                  ])
                ])
              end,
              trivia,
              {(r, _, b, p) =>
                let str =
                  recover val
                    String.>concat(r.start.values(p.src_info().start()))
                  end
                (ast.Identifier(_Build.info(r), p, str), b)
              }
            ))
        end
      _identifier = identifier'
      identifier'
    end

  fun ref annotation(): NamedRule =>
    match _annotation
    | let r: NamedRule => r
    else
      let bs = _token.backslash()
      let comma = _token.comma()
      let id = identifier()

      let annotation' =
        recover val
          NamedRule("Annotation",
            Conj([
              bs
              id
              Star(Conj([ comma; id ]))
              bs
            ]))
        end
      _annotation = annotation'
      annotation'
    end

  fun ref seq(): NamedRule =>
    match _exp_seq
    | let r: NamedRule => r
    else
      _build_seq()._1
    end

  fun ref item(): NamedRule =>
    match _exp_item
    | let r: NamedRule => r
    else
      _build_seq()._2
    end

  fun ref _build_seq(): (NamedRule, NamedRule) =>
    let binary_op = _operator.binary_op()
    let equals = _token.equals()
    let id = identifier()
    let kwd = _keyword.kwd()
    let kwd_as = _keyword.kwd_as()
    let kwd_break = _keyword.kwd_break()
    let kwd_compile_error = _keyword.kwd_compile_error()
    let kwd_compile_intrinsic = _keyword.kwd_compile_intrinsic()
    let kwd_continue = _keyword.kwd_continue()
    let kwd_else = _keyword.kwd_else()
    let kwd_elseif = _keyword.kwd_elseif()
    let kwd_end = _keyword.kwd_end()
    let kwd_error = _keyword.kwd_error()
    let kwd_if = _keyword.kwd_if()
    let kwd_ifdef = _keyword.kwd_ifdef()
    let kwd_iftype = _keyword.kwd_iftype()
    let kwd_loc = _keyword.kwd_loc()
    let kwd_return = _keyword.kwd_return()
    let kwd_then = _keyword.kwd_then()
    let kwd_this = _keyword.kwd_this()
    let literal = _literal.literal()
    let postfix_op = _operator.postfix_op()
    let prefix_op = _operator.prefix_op()
    let semicolon = _token.semicolon()
    let trivia = _trivia.trivia()
    let type_rule = _type.type_rule()
    let subtype = _token.subtype()

    // we need to build these in one go since they are mutually recursive
    (let exp_seq', let exp_item') =
      recover val
        let exp_seq = NamedRule("Expression_Sequence", None)               // x
        let exp_item = NamedRule("Expression_Item", None)                  // x
        let exp_assignment = NamedRule("Expression_Assignment", None)      // x
        let exp_infix = NamedRule("Expression_Infix", None)                // x
        let exp_jump = NamedRule("Expression_Jump", None)                  // x
        let exp_term = NamedRule("Expression_Term", None)                  // x
        let exp_if = NamedRule("Expression_If", None)                      // x
        let exp_cond = NamedRule("Expression_IfCondition", None)           // x
        let exp_elsif = NamedRule("Expression_Elsif", None)                // x
        let exp_ifdef = NamedRule("Expression_IfDef", None)                // x
        let exp_iftype = NamedRule("Expression_IfType", None)
        let exp_match = NamedRule("Expression_Match", None)
        let exp_while = NamedRule("Expression_While", None)
        let exp_repeat = NamedRule("Expression_Repeat", None)
        let exp_for = NamedRule("Expression_For", None)
        let exp_with = NamedRule("Expression_With", None)
        let exp_try = NamedRule("Expression_Try", None)
        let exp_recover = NamedRule("Expression_Recover", None)
        let exp_consume = NamedRule("Expression_Consume", None)
        let exp_hash = NamedRule("Expression_Hash", None)
        let exp_decl = NamedRule("Expression_Declaration", None)
        let exp_prefix = NamedRule("Expression_Prefix", None)              // x
        let exp_postfix = NamedRule("Expression_Postfix", None)            // x
        let exp_tuple = NamedRule("Expression_Tuple", None)
        let exp_parens = NamedRule("Expression_Parenthesized", None)
        let exp_array = NamedRule("Expression_Array", None)
        let exp_ffi = NamedRule("Expression_Ffi", None)
        let exp_bare_lambda = NamedRule("Expression_BareLambda", None)
        let exp_lambda = NamedRule("Expression_Lambda", None)
        let exp_object = NamedRule("Expression_Object", None)
        let exp_atom = NamedRule("Expression_Atom", None)                  // x
        let type_params = NamedRule("Expression_TypeParams", None)
        let call_params = NamedRule("Expression_CallParams", None)

        let ann = Variable("ann")
        let body = Variable("body")
        let lhs = Variable("lhs")
        let op = Variable("op")
        let rhs = Variable("rhs")
        let params = Variable("params")
        let firstif = Variable("firstif")
        let elseifs = Variable("elseifs")
        let condition = Variable("condition")
        let if_true = Variable("if_true")
        let then_block = Variable("then_block")
        let else_block = Variable("else_block")
        let keyword = Variable("keyword")

        // seq <= annotation? item (';'? item)*
        exp_seq.set_body(
          Conj([
            Bind(ann, Ques(annotation()))
            Bind(body,
              Conj([
                exp_item
                Star(
                  Conj([
                    Ques(semicolon)
                    exp_item
                  ]))
              ]))
          ],
          this~_annotation_action[ast.Sequence](ann, body, this~_seq_body()))
        )

        // item <= assignment / jump
        exp_item.set_body(
          Disj([
            exp_assignment
            exp_jump
            exp_infix
          ]))

        // assignment <= (infix '=' assignment) / infix
        exp_assignment.set_body(
          Disj([
            Conj([
              Bind(lhs, exp_infix)
              Bind(op, equals)
              Bind(rhs, exp_assignment)
            ], this~_binop_action(lhs, op, rhs))
            exp_infix
          ]))

        // infix <= (term binary_op infix) / (term 'as' type) / term
        exp_infix.set_body(
          Disj([
            Disj([
              Conj([
                Bind(lhs, exp_term)
                Bind(op, binary_op)
                Bind(rhs, exp_infix)
              ])
              Conj([
                Bind(lhs, exp_term)
                Bind(op, kwd_as)
                Bind(rhs, type_rule)
              ])
            ], this~_binop_action(lhs, op, rhs))
            exp_term
          ]))

        // term <= if / ifdef / iftype / match / while / repeate / for / with /
        //         try / recover / consume / decl / prefix / hash
        exp_term.set_body(
          Disj([
            exp_if
            exp_ifdef
            exp_iftype
            exp_match
            exp_while
            exp_repeat
            exp_for
            exp_with
            exp_try
            exp_recover
            exp_consume
            exp_decl
            exp_prefix
            exp_hash
          ]))

        // if <= 'if' cond ('elsif' cond)* ('else' seq)? 'end'
        exp_if.set_body(
          Conj([
            kwd_if
            Bind(firstif, exp_cond)
            Bind(elseifs,
              Star(
                Conj([
                  kwd_elseif
                  exp_cond
                ])))
            Ques(
              Conj([
                kwd_else
                Bind(else_block, exp_seq)
              ]))
            kwd_end
          ],
          this~_if_action(firstif, elseifs, else_block)))

        // ifdef <= 'ifdef' cond ('elseif' cond)* ('else' seq)? 'end'
        exp_ifdef.set_body(
          Conj([
            kwd_ifdef
            Bind(firstif, exp_cond)
            Bind(elseifs,
              Star(
                Conj([
                  kwd_elseif
                  exp_cond
                ])))
            Ques(
              Conj([
                kwd_else
                Bind(else_block, exp_seq)
              ]))
            kwd_end
          ],
          this~_ifdef_action(firstif, elseifs, else_block)))

        // iftype <= 'iftype' type '<:' type 'then' seq ('elseif' type '<:' type)*
        //           ('else' seq)? 'end'
        exp_iftype.set_body(
          Conj([
            kwd_iftype
            Bind(firstif,
              Conj([
                Bind(if_true,
                  Conj([
                    Bind(lhs, type_rule)
                    Bind(op, subtype)
                    Bind(rhs, type_rule)
                  ]))
                kwd_then
                Bind(then_block, exp_seq)
              ],
              this~_iftype_cond_action(if_true, lhs, op, rhs, then_block)))
            Bind(elseifs,
              Star(
                Conj([
                  kwd_elseif
                  Bind(if_true,
                    Conj([
                      Bind(lhs, type_rule)
                      Bind(op, subtype)
                      Bind(rhs, type_rule)
                    ]))
                  kwd_then
                  Bind(then_block, exp_seq)
                ],
                this~_iftype_cond_action(if_true, lhs, op, rhs, then_block))))
            Ques(
              Conj([
                kwd_else
                Bind(else_block, exp_seq)
              ]))
            kwd_end
          ],
          this~_iftype_action(firstif, elseifs, else_block)))

        // cond <= seq 'then' seq
        exp_cond.set_body(
          Conj([
            Bind(if_true, exp_seq)
            kwd_then
            Bind(then_block, exp_seq)
          ],
          this~_ifcond_action(if_true, then_block)))

        // prefix <= (prefix_op prefix) / postfix
        exp_prefix.set_body(
          Disj([
            Conj([
              Bind(op, prefix_op)
              Bind(rhs, exp_prefix)
            ], this~_prefix_action(op, rhs))
            exp_postfix
          ]))

        // postfix <= (postfix postfix_op identifier) /
        //            (postfix type_params) /
        //            (postfix call_params) /
        //            atom
        exp_postfix.set_body(
          Disj([
            Conj([
              Bind(lhs, exp_postfix)
              Bind(op, postfix_op)
              Bind(rhs, id)
            ], this~_binop_action(lhs, op, rhs))
            Conj([
              Bind(lhs, exp_postfix)
              Bind(params, type_params)
            ], this~_postfix_type_action(lhs, params))
            Conj([
              Bind(lhs, exp_postfix)
              Bind(params, call_params)
            ], this~_postfix_call_action(lhs, params))
            exp_atom
          ]))

        exp_jump.set_body(
          Disj([
            Conj([
              Disj([
                Bind(keyword, kwd_return)
                Bind(keyword, kwd_break)
              ])
              Ques(Bind(rhs, Disj([ exp_assignment; exp_infix ])))
            ])
            Bind(keyword, kwd_continue)
            Bind(keyword, kwd_error)
            Bind(keyword, kwd_compile_intrinsic)
            Bind(keyword, kwd_compile_error)
          ],
          this~_jump_action(keyword, rhs)))

        exp_atom.set_body(
          Disj([
            exp_tuple
            exp_parens
            exp_array
            exp_ffi
            exp_bare_lambda
            exp_lambda
            exp_object
            kwd_loc
            kwd_this
            literal
            Conj([
              Neg(kwd)
              id
            ])
          ]))

        (exp_seq, exp_item)
      end
    _exp_seq = exp_seq'
    _exp_item = exp_item'
    (exp_seq', exp_item')

  fun tag _annotation_action[T: ast.Node val](
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

    try
      let ann' = _Build.values(b, ann)?
      let ids =
        recover val
          Array[ast.Identifier].>concat(Iter[ast.Node](ann'.values())
            .filter_map[ast.Identifier](
              {(n) => try n as ast.Identifier end }))
        end
      if ids.size() > 0 then
        return (ast.Annotation(_Build.info(r), c, ids, body_value), b)
      end
    end
    (body_value, b)

  fun tag _seq_body(r: Success, c: ast.NodeSeq[ast.Node]) : ast.Sequence =>
    ast.Sequence(_Build.info(r), c)

  fun tag _binop_action(
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
    (ast.Operation(_Build.info(r), c, lhs', op', rhs'), b)

  fun tag _if_action(
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
      try
        recover val
          Array[ast.IfCondition].>concat(
            Iter[ast.Node](_Build.values(b, elseifs)?.values())
              .filter_map[ast.IfCondition](
                {(n) => try n as ast.IfCondition end }))
        end
      else
        return _Build.bind_error(r, c, b, "Expression/If/Elsifs")
      end
    let else_block' =
      try
        _Build.value_or_none(b, else_block)?
      else
        return _Build.bind_error(r, c, b, "Expression/If/ElseSeq")
      end
    let conditions =
      recover val
        let conditions' = Array[ast.IfCondition](1 + elseifs'.size())
        conditions'.push(firstif')
        conditions'.append(elseifs')
        conditions'
      end

    (ast.If(_Build.info(r), c, conditions, else_block'), b)

  fun tag _ifdef_action(
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
      try
        recover val
          Array[ast.IfCondition].>concat(
            Iter[ast.Node](_Build.values(b, elseifs)?.values())
              .filter_map[ast.IfCondition](
                {(n) => try n as ast.IfCondition end }))
        end
      else
        return _Build.bind_error(r, c, b, "Expression/If/Elsifs")
      end
    let else_block' =
      try
        _Build.value_or_none(b, else_block)?
      else
        return _Build.bind_error(r, c, b, "Expression/If/ElseSeq")
      end
    let conditions =
      recover val
        let conditions' = Array[ast.IfCondition](1 + elseifs'.size())
        conditions'.push(firstif')
        conditions'.append(elseifs')
        conditions'
      end

    (ast.IfDef(_Build.info(r), c, conditions, else_block'), b)

  fun tag _iftype_action(
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
      try
        recover val
          Array[ast.IfCondition].>concat(
            Iter[ast.Node](_Build.values(b, elseifs)?.values())
              .filter_map[ast.IfCondition](
                {(n) => try n as ast.IfCondition end }))
        end
      else
        return _Build.bind_error(r, c, b, "Expression/IfType/Elseifs")
      end
    let else_block' =
      try
        _Build.value_or_none(b, else_block)?
      else
        return _Build.bind_error(r, c, b, "Expression/IfType/ElseSeq")
      end
    let conditions =
      recover val
        Array[ast.IfCondition](1 + elseifs'.size())
          .>push(firstif')
          .>append(elseifs')
      end

    (ast.IfType(_Build.info(r), c, conditions, else_block'), b)

  fun tag _ifcond_action(
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

  fun tag _iftype_cond_action(
    if_true: Variable,
    lhs: Variable,
    op: Variable,
    rhs: Variable,
    then_block: Variable,
    r: Success,
    c: ast.NodeSeq[ast.Node],
    b: Bindings): ((ast.Node | None), Bindings)
  =>
    let cond_children =
      try
        _Build.values(b, if_true)?
      else
        return _Build.bind_error(r, c, b, "Expression/IfTypeConf/IfTrue")
      end
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
    let cond = ast.Operation(cond_info, cond_children, lhs', op', rhs')

    (ast.IfCondition(_Build.info(r), c, cond, then_block'), b)

  fun tag _prefix_action(
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
    (ast.Operation(_Build.info(r), c, None, op', rhs'), b)

  fun tag _postfix_type_action(
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
        return _Build.bind_error(r, c, b, "Expression/Postfix/Op")
      end
    let params' =
      try
        _Build.values(b, params)?
      else
        return _Build.bind_error(r, c, b, "Expression/Postfix/Params")
      end
    (ast.TypeParams(_Build.info(r), c, lhs', params'), b)

  fun tag _postfix_call_action(
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
        return _Build.bind_error(r, c, b, "Expression/Postfix/Op")
      end
    let params' =
      try
        _Build.values(b, params)?
      else
        return _Build.bind_error(r, c, b, "Expression/Postfix/Params")
      end
    (ast.Call(_Build.info(r), c, lhs', params'), b)

  fun tag _jump_action(
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
    (ast.Jump(_Build.info(r), c, keyword', rhs'), b)
