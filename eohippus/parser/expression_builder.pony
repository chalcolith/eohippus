use "itertools"

use ast = "../ast"

class ExpressionBuilder
  let _context: Context

  let _trivia: TriviaBuilder
  let _token: TokenBuilder
  let _keyword: KeywordBuilder
  let _operator: OperatorBuilder
  let _literal: LiteralBuilder
  let _type_type: TypeBuilder

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
    type_type: TypeBuilder)
  =>
    _context = context
    _trivia = trivia
    _token = token
    _keyword = keyword
    _operator = operator
    _literal = literal
    _type_type = type_type

  fun ref annotation(): NamedRule =>
    match _annotation
    | let r: NamedRule => r
    else
      let bs = _token(ast.Tokens.backslash())
      let comma = _token(ast.Tokens.comma())
      let id = _token.identifier()

      let annotation' =
        recover val
          NamedRule(
            "Annotation",
            Conj(
              [ bs
                id
                Star(Conj([ comma; id ]))
                bs ],
              _ExpActions~_annotation()))
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
    let amp = _token(ast.Tokens.amp())
    let arrow = _token(ast.Tokens.arrow())
    let bar = _token(ast.Tokens.bar())
    let binary_op = _operator.binary_op()
    let ccurly = _token(ast.Tokens.close_curly())
    let colon = _token(ast.Tokens.colon())
    let comma = _token(ast.Tokens.comma())
    let cparen = _token(ast.Tokens.close_paren())
    let csquare = _token(ast.Tokens.close_square())
    let dot = _token(ast.Tokens.dot())
    let equals = _token(ast.Tokens.equals())
    let hash = _token(ast.Tokens.hash())
    let id = _token.identifier()
    let kwd = _keyword.kwd()
    let kwd_as = _keyword(ast.Keywords.kwd_as())
    let kwd_break = _keyword(ast.Keywords.kwd_break())
    let kwd_cap = _keyword.cap()
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
    let kwd_is = _keyword(ast.Keywords.kwd_is())
    let kwd_loc = _keyword(ast.Keywords.kwd_loc())
    let kwd_recover = _keyword(ast.Keywords.kwd_recover())
    let kwd_return = _keyword(ast.Keywords.kwd_return())
    let kwd_then = _keyword(ast.Keywords.kwd_then())
    let kwd_this = _keyword(ast.Keywords.kwd_this())
    let kwd_try = _keyword(ast.Keywords.kwd_try())
    let kwd_where = _keyword(ast.Keywords.kwd_where())
    let literal = _literal.literal()
    let not_kwd = _keyword.not_kwd()
    let ocurly = _token(ast.Tokens.open_curly())
    let oparen = _token(ast.Tokens.open_paren())
    let osquare = _token(ast.Tokens.open_square())
    let postfix_op = _operator.postfix_op()
    let prefix_op = _operator.prefix_op()
    let ques = _token(ast.Tokens.ques())
    let semicolon = _token(ast.Tokens.semicolon())
    let subtype = _token(ast.Tokens.subtype())
    let trivia = _trivia.trivia()
    let type_args = _type_type.args()
    let type_arrow = _type_type.arrow()

    // we need to build these in one go since they are mutually recursive
    (let exp_seq', let exp_item') =
      recover val
        let call_arg_named = NamedRule("Exp_CallArg_Named", None)           // x
        let call_args = NamedRule("Exp_CallArgs", None)                     // x
        let call_args_named = NamedRule("Exp_CallArgs_Named", None)         // x
        let call_args_pos = NamedRule("Exp_CallArgs_Pos", None)             // x
        let exp_array = NamedRule("Exp_Array", None)
        let exp_assignment = NamedRule("Exp_Assignment", None)              // x
        let exp_atom = NamedRule("Exp_Atom", None)                          // x
        let exp_cond = NamedRule("Exp_IfCondition", None)                   // x
        let exp_consume = NamedRule("Exp_Consume", None)
        let exp_decl = NamedRule("Exp_Declaration", None)
        let exp_elsif = NamedRule("Exp_Elsif", None)                        // x
        let exp_ffi = NamedRule("Exp_Ffi", None)
        let exp_for = NamedRule("Exp_For", None)
        let exp_hash = NamedRule("Exp_Hash", None)                          // x
        let exp_if = NamedRule("Exp_If", None)                              // x
        let exp_ifdef = NamedRule("Exp_IfDef", None)                        // x
        let exp_iftype = NamedRule("Exp_IfType", None)                      // x
        let exp_infix = NamedRule("Exp_Infix", None)                        // x
        let exp_item = NamedRule("Exp_Item", None)                          // x
        let exp_jump = NamedRule("Exp_Jump", None)                          // x
        let exp_lambda = NamedRule("Exp_Lambda", None)
        let exp_match = NamedRule("Exp_Match", None)
        let exp_object = NamedRule("Exp_Object", None)
        let exp_parens = NamedRule("Exp_Parens", None)                      // x
        let exp_postfix = NamedRule("Exp_Postfix", None)                    // x
        let exp_prefix = NamedRule("Exp_Prefix", None)                      // x
        let exp_recover = NamedRule("Exp_Recover", None)                    // x
        let exp_repeat = NamedRule("Exp_Repeat", None)
        let exp_seq = NamedRule("Exp_Sequence", None)                       // x
        let exp_term = NamedRule("Exp_Term", None)                          // x
        let exp_try = NamedRule("Exp_Try", None)                            // x
        let exp_tuple = NamedRule("Exp_Tuple", None)                        // x
        let exp_while = NamedRule("Exp_While", None)
        let exp_with = NamedRule("Exp_With", None)

        // seq <= annotation? item (';'? item)*
        let seq_ann = Variable("seq_ann")
        let seq_body = Variable("seq_body")
        exp_seq.set_body(
          Conj(
            [ Bind(seq_ann, Ques(annotation()))
              Bind(
                seq_body,
                Conj(
                  [ exp_item
                    Star(
                      Conj(
                        [ Ques(semicolon)
                          exp_item ]))
                  ]))
            ],
            _ExpActions~_seq(seq_ann, seq_body)))

        // item <= assignment / jump / infix
        exp_item.set_body(
          Disj(
            [ exp_assignment
              exp_jump
              exp_infix ]))

        // assignment <= (infix '=' assignment) / infix
        let ass_lhs = Variable("ass_lhs")
        let ass_op = Variable("ass_op")
        let ass_rhs = Variable("ass_rhs")
        exp_assignment.set_body(
          Disj(
            [ Conj(
                [ Bind(ass_lhs, exp_infix)
                  Bind(ass_op, equals)
                  Bind(ass_rhs, exp_assignment) ],
                _ExpActions~_binop(ass_lhs, ass_op, ass_rhs, None))
            exp_infix ]))

        // jump <= ('return' / 'break') assignment? /
        //         'continue' /
        //         'error' /
        //         'compile_intrinsic' /
        //         'compile_error'
        let jump_keyword = Variable("jump_keyword")
        let jump_rhs = Variable("jump_rhs")
        exp_jump.set_body(
          Disj(
            [ Conj(
                [ Disj(
                    [ Bind(jump_keyword, kwd_return)
                      Bind(jump_keyword, kwd_break) ])
                  Ques(Bind(jump_rhs, exp_assignment)) ])
              Bind(jump_keyword, kwd_continue)
              Bind(jump_keyword, kwd_error)
              Bind(jump_keyword, kwd_compile_intrinsic)
              Bind(jump_keyword, kwd_compile_error) ],
            _ExpActions~_jump(jump_keyword, jump_rhs)))

        // infix <= (term binary_op infix) / (term 'as' type) / term
        let infix_lhs = Variable("infix_lhs")
        let infix_op = Variable("infix_op")
        let infix_partial = Variable("infix_partial")
        let infix_rhs = Variable("infix_rhs")
        exp_infix.set_body(
          Disj(
            [ Disj(
                [ Conj(
                    [ Bind(infix_lhs, exp_term)
                      Bind(infix_op, kwd_as)
                      Bind(infix_rhs, type_arrow) ])
                  Conj(
                    [ Bind(infix_lhs, exp_term)
                      Bind(infix_op, kwd_is)
                      Bind(infix_rhs, exp_infix) ])
                  Conj(
                    [ Bind(infix_lhs, exp_term)
                      Bind(infix_op, binary_op)
                      Ques(Bind(infix_partial, ques))
                      Bind(infix_rhs, exp_infix) ])
                ],
                _ExpActions~_binop(
                  infix_lhs, infix_op, infix_rhs, infix_partial))
              exp_term ]))

        // term <= if / ifdef / iftype / match / while / repeate / for / with /
        //         try / recover / consume / decl / prefix / hash
        exp_term.set_body(
          Disj(
            [ exp_if
              exp_ifdef
              exp_iftype
              //exp_match
              //exp_while
              //exp_repeat
              //exp_for
              //exp_with
              exp_try
              exp_recover
              //exp_consume
              //exp_decl
              exp_prefix
              //exp_hash
            ]))

        // if <= 'if' cond ('elsif' cond)* ('else' seq)? 'end'
        let if_firstif = Variable("if_firstif")
        let if_elseifs = Variable("if_elseifs")
        let if_else_block = Variable("if_else_block")
        exp_if.set_body(
          Conj(
            [ kwd_if
              Bind(if_firstif, exp_cond)
              Bind(
                if_elseifs,
                Star(
                  Conj(
                    [ kwd_elseif
                      exp_cond ])))
              Ques(
                Conj(
                  [ kwd_else
                    Bind(if_else_block, exp_seq) ]))
              kwd_end ],
            _ExpActions~_if(if_firstif, if_elseifs, if_else_block)))

        // cond <= seq 'then' seq
        let cond_if_true = Variable("cond_if_true")
        let cond_then_block = Variable("cond_then_block")
        exp_cond.set_body(
          Conj(
            [ Bind(cond_if_true, exp_seq)
              kwd_then
              Bind(cond_then_block, exp_seq) ],
            _ExpActions~_ifcond(cond_if_true, cond_then_block)))

        // ifdef <= 'ifdef' cond ('elseif' cond)* ('else' seq)? 'end'
        let ifdef_firstif = Variable("ifdef_firstif")
        let ifdef_elseifs = Variable("ifdef_elseifs")
        let ifdef_else_block = Variable("ifdef_else_block")
        exp_ifdef.set_body(
          Conj(
            [ kwd_ifdef
              Bind(ifdef_firstif, exp_cond)
              Bind(
                ifdef_elseifs,
                Star(
                  Conj(
                    [ kwd_elseif
                      exp_cond ])))
              Ques(
                Conj(
                  [ kwd_else
                    Bind(ifdef_else_block, exp_seq) ]))
              kwd_end ],
            _ExpActions~_ifdef(ifdef_firstif, ifdef_elseifs, ifdef_else_block)))

        // iftype <= 'iftype' type '<:' type 'then' seq ('elseif' type '<:' type)*
        //           ('else' seq)? 'end'
        let iftype_firstif = Variable("iftype_firstif")
        let iftype_if_true = Variable("iftype_if_true")
        let iftype_lhs = Variable("iftype_lhs")
        let iftype_op = Variable("iftype_op")
        let iftype_rhs = Variable("iftype_rhs")
        let iftype_then_block = Variable("iftype_then_block")
        let iftype_elseifs = Variable("iftype_elseifs")
        let iftype_else_block = Variable("iftype_else_block")
        exp_iftype.set_body(
          Conj(
            [ kwd_iftype
              Bind(
                iftype_firstif,
                Conj(
                  [ Bind(iftype_if_true,
                      Conj(
                        [ Bind(iftype_lhs, type_arrow)
                          Bind(iftype_op, subtype)
                          Bind(iftype_rhs, type_arrow) ]))
                    kwd_then
                    Bind(iftype_then_block, exp_seq) ],
                  _ExpActions~_iftype_cond(
                    iftype_if_true,
                    iftype_lhs,
                    iftype_op,
                    iftype_rhs,
                    iftype_then_block)))
              Bind(
                iftype_elseifs,
                Star(
                  Conj(
                    [ kwd_elseif
                      Bind(iftype_if_true,
                        Conj(
                          [ Bind(iftype_lhs, type_arrow)
                            Bind(iftype_op, subtype)
                            Bind(iftype_rhs, type_arrow) ]))
                      kwd_then
                      Bind(iftype_then_block, exp_seq) ],
                    _ExpActions~_iftype_cond(
                      iftype_if_true,
                      iftype_lhs,
                      iftype_op,
                      iftype_rhs,
                      iftype_then_block))))
              Ques(
                Conj(
                  [ kwd_else
                    Bind(iftype_else_block, exp_seq) ]))
              kwd_end ],
            _ExpActions~_iftype(
              iftype_firstif, iftype_elseifs, iftype_else_block)))

        // try <= 'try' seq ('else' seq)? 'end'
        let try_body = Variable("try_body")
        let try_else_block = Variable("try_else_block")
        exp_try.set_body(
          Conj(
            [ kwd_try
              Bind(try_body, exp_seq)
              Ques(Conj([ kwd_else; Bind(try_else_block, exp_seq) ]))
              kwd_end ]),
          _ExpActions~_try(try_body, try_else_block))

        // recover <= 'recover' cap? seq 'end'
        let recover_cap = Variable("recover_cap")
        let recover_body = Variable("recover_body")
        exp_recover.set_body(
          Conj(
            [ kwd_recover
              Ques(Bind(recover_cap, kwd_cap))
              Bind(recover_body, exp_seq)
              kwd_end ]),
          _ExpActions~_recover(recover_cap, recover_body))

        // prefix <= (prefix_op prefix) / postfix
        let prefix_opv = Variable("prefix_opv")
        let prefix_rhs = Variable("prefix_rhs")
        exp_prefix.set_body(
          Disj(
            [ Conj(
                [ Bind(prefix_opv, prefix_op)
                  Bind(prefix_rhs, exp_prefix) ],
                _ExpActions~_prefix(prefix_opv, prefix_rhs))
              exp_postfix ]))

        // exp_hash <= '#' exp_postfix
        let hash_rhs = Variable("hash_rhs")
        exp_hash.set_body(
          Conj(
            [ hash
              Bind(hash_rhs, exp_postfix) ]),
            _ExpActions~_hash(hash_rhs))

        // postfix <= (postfix postfix_op identifier) /
        //            (postfix type_args) /
        //            (postfix call_args) /
        //            atom
        let postfix_lhs = Variable("postfix_lhs")
        let postfix_opv = Variable("postfix_opv")
        let postfix_rhs = Variable("postfix_rhs")
        let postfix_args = Variable("postfix_type_args")
        let postfix_partial = Variable("postfix_partial")
        exp_postfix.set_body(
          Disj(
            [ Conj(
                [ Bind(postfix_lhs, exp_postfix)
                  Bind(postfix_opv, postfix_op)
                  Bind(postfix_rhs, id) ],
                _ExpActions~_binop(postfix_lhs, postfix_opv, postfix_rhs, None))
              Conj(
                [ Bind(postfix_lhs, exp_postfix)
                  Bind(postfix_args, type_args) ],
                _ExpActions~_postfix_type_args(postfix_lhs, postfix_args))
              Conj(
                [ Bind(postfix_lhs, exp_postfix)
                  Bind(postfix_args, call_args)
                  Ques(Bind(postfix_partial, ques)) ],
                _ExpActions~_postfix_call_args(
                  postfix_lhs, postfix_args, postfix_partial))
              exp_atom ]))

        // atom <= tuple / parens / array / ffi / bare_lambda / lambda /
        //         object / '__loc' / 'this' / literal / (~keyword identifier)
        let atom_body = Variable("atom_body")
        exp_atom.set_body(
          Bind(atom_body,
            Disj(
              [ exp_tuple
                exp_parens
                exp_array
                //exp_ffi
                //exp_lambda
                //exp_object
                kwd_loc
                kwd_this
                literal
                Conj([ not_kwd; id ]) ])),
          _ExpActions~_atom(atom_body))

        // call_args <= '(' call_args_pos? call_args_named? ')'
        let call_args_posv = Variable("call_args_posv")
        let call_args_namedv = Variable("call_args_named")
        call_args.set_body(
          Conj(
            [ oparen
              Ques(Bind(call_args_posv, call_args_pos))
              Ques(Bind(call_args_namedv, call_args_named))
              cparen ]),
          _ExpActions~_call_args(call_args_posv, call_args_namedv))

        // call_args_pos <= exp_seq (',' exp_seq)*
        call_args_pos.set_body(
          Conj(
            [ exp_seq
              Star(
                Conj(
                  [ comma
                    exp_seq ])) ]))

        // call_args_named <= 'where' call_arg_named
        //                    (',' call_arg_named)*
        call_args_named.set_body(
          Conj(
            [ kwd_where
              call_arg_named
              Star(
                Conj(
                  [ comma
                    call_arg_named ])) ]))

        // call_arg_named <= identifier '=' exp_seq
        let call_arg_name = Variable("call_arg_named_name")
        let call_arg_op = Variable("call_arg_named_op")
        let call_arg_rhs = Variable("call_arg_named_rhs")
        call_arg_named.set_body(
          Conj(
            [ Bind(call_arg_name, id)
              Bind(call_arg_op, equals)
              Bind(call_arg_rhs, exp_seq) ]),
          _ExpActions~_binop(
             call_arg_name, call_arg_op, call_arg_rhs, None))

        // tuple <= '(' seq (',' seq)+ ')'
        let tuple_seqs = Variable("tuple_seqs")
        exp_tuple.set_body(
          Bind(
            tuple_seqs,
            Conj(
              [ oparen
                exp_seq
                Plus(
                  Conj(
                    [ comma
                      exp_seq ]))
                cparen ])),
          _ExpActions~_tuple(tuple_seqs))

        // parens <= '(' seq ')'
        let parens_body = Variable("parens_body")
        exp_parens.set_body(
          Conj(
            [ oparen
              Bind(parens_body, exp_seq) ]),
          _ExpActions~_atom(parens_body))

        // array <= '[' ('as' type_arrow ':') exp_seq ']'
        let array_type = Variable("array_type")
        let array_body = Variable("array_body")
        exp_array.set_body(
          Conj(
            [ osquare
              Ques(
                Conj(
                  [ kwd_as
                    Bind(array_type, type_arrow)
                    colon ]))
              Bind(array_body, exp_seq)
              csquare ]),
          _ExpActions~_array(array_type, array_body))

        //
        (exp_seq, exp_item)
      end
    _exp_seq = exp_seq'
    _exp_item = exp_item'
    (exp_seq', exp_item')
