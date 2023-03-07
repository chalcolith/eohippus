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

  var _not_kwd: (NamedRule | None) = None
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

  fun ref not_kwd(): NamedRule =>
    match _not_kwd
    | let r: NamedRule => r
    else
      let kwd = _keyword.kwd()
      recover val
        NamedRule("NotKwd", Neg(kwd))
      end
    end

  fun ref annotation(): NamedRule =>
    match _annotation
    | let r: NamedRule => r
    else
      let bs = _token(ast.Tokens.backslash())
      let comma = _token(ast.Tokens.comma())
      let id = _token.identifier()

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
    let equals = _token(ast.Tokens.equals())
    let id = _token.identifier()
    let kwd = _keyword.kwd()
    let kwd_as = _keyword(ast.Keywords.kwd_as())
    let kwd_break = _keyword(ast.Keywords.kwd_break())
    let kwd_compile_error = _keyword(ast.Keywords.kwd_compile_error())
    let kwd_compile_intrinsic = _keyword(ast.Keywords.kwd_compile_intrinsic())
    let kwd_continue = _keyword(ast.Keywords.kwd_continue())
    let kwd_else = _keyword(ast.Keywords.kwd_else())
    let kwd_elseif = _keyword(ast.Keywords.kwd_elseif())
    let kwd_end = _keyword(ast.Keywords.kwd_end())
    let kwd_error = _keyword(ast.Keywords.kwd_error())
    let kwd_if = _keyword(ast.Keywords.kwd_if())
    let kwd_ifdef = _keyword(ast.Keywords.kwd_ifdef())
    let kwd_iftype = _keyword(ast.Keywords.kwd_iftype())
    let kwd_loc = _keyword(ast.Keywords.kwd_loc())
    let kwd_return = _keyword(ast.Keywords.kwd_return())
    let kwd_then = _keyword(ast.Keywords.kwd_then())
    let kwd_this = _keyword(ast.Keywords.kwd_this())
    let literal = _literal.literal()
    let not_kwd' = not_kwd()
    let postfix_op = _operator.postfix_op()
    let prefix_op = _operator.prefix_op()
    let semicolon = _token(ast.Tokens.semicolon())
    let subtype = _token(ast.Tokens.subtype())
    let trivia = _trivia.trivia()
    let type_type = _type.type_type()

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
          _ExpActions~_annotation[ast.Sequence](ann, body, this~_seq_body()))
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
            ], _ExpActions~_binop(lhs, op, rhs))
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
                Bind(rhs, type_type)
              ])
            ], _ExpActions~_binop(lhs, op, rhs))
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
          _ExpActions~_if(firstif, elseifs, else_block)))

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
          _ExpActions~_ifdef(firstif, elseifs, else_block)))

        // iftype <= 'iftype' type '<:' type 'then' seq ('elseif' type '<:' type)*
        //           ('else' seq)? 'end'
        exp_iftype.set_body(
          Conj([
            kwd_iftype
            Bind(firstif,
              Conj([
                Bind(if_true,
                  Conj([
                    Bind(lhs, type_type)
                    Bind(op, subtype)
                    Bind(rhs, type_type)
                  ]))
                kwd_then
                Bind(then_block, exp_seq)
              ],
              _ExpActions~_iftype_cond(if_true, lhs, op, rhs, then_block)))
            Bind(elseifs,
              Star(
                Conj([
                  kwd_elseif
                  Bind(if_true,
                    Conj([
                      Bind(lhs, type_type)
                      Bind(op, subtype)
                      Bind(rhs, type_type)
                    ]))
                  kwd_then
                  Bind(then_block, exp_seq)
                ],
                _ExpActions~_iftype_cond(if_true, lhs, op, rhs, then_block))))
            Ques(
              Conj([
                kwd_else
                Bind(else_block, exp_seq)
              ]))
            kwd_end
          ],
          _ExpActions~_iftype(firstif, elseifs, else_block)))

        // cond <= seq 'then' seq
        exp_cond.set_body(
          Conj([
            Bind(if_true, exp_seq)
            kwd_then
            Bind(then_block, exp_seq)
          ],
          _ExpActions~_ifcond(if_true, then_block)))

        // prefix <= (prefix_op prefix) / postfix
        exp_prefix.set_body(
          Disj([
            Conj([
              Bind(op, prefix_op)
              Bind(rhs, exp_prefix)
            ], _ExpActions~_prefix(op, rhs))
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
            ], _ExpActions~_binop(lhs, op, rhs))
            Conj([
              Bind(lhs, exp_postfix)
              Bind(params, type_params)
            ], _ExpActions~_postfix_type(lhs, params))
            Conj([
              Bind(lhs, exp_postfix)
              Bind(params, call_params)
            ], _ExpActions~_postfix_call(lhs, params))
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
          _ExpActions~_jump(keyword, rhs)))

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
              not_kwd'
              id
            ])
          ]))

        (exp_seq, exp_item)
      end
    _exp_seq = exp_seq'
    _exp_item = exp_item'
    (exp_seq', exp_item')

  fun tag _seq_body(r: Success, c: ast.NodeSeq[ast.Node]) : ast.Sequence =>
    ast.Sequence(_Build.info(r), c)
