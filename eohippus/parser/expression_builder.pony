use "itertools"

use ".."
use ast = "../ast"

class ExpressionBuilder
  let _context: Context

  let _trivia: TriviaBuilder
  let _token: TokenBuilder
  let _keyword: KeywordBuilder
  let _operator: OperatorBuilder
  let _literal: LiteralBuilder
  let _type_type: TypeBuilder

  let annotation: NamedRule = NamedRule("an annotation" where memoize' = true)
  let item: NamedRule = NamedRule("an expression" where memoize' = true)
  let infix: NamedRule = NamedRule("an infix expression" where memoize' = true)
  let seq: NamedRule = NamedRule("an expression sequence" where memoize' = true)
  let tuple_pattern: NamedRule = NamedRule("a tuple destructuring pattern")
  let _method_params: NamedRule
  let _typedef_members: NamedRule

  new create(
    context: Context,
    trivia: TriviaBuilder,
    token: TokenBuilder,
    keyword: KeywordBuilder,
    operator: OperatorBuilder,
    literal: LiteralBuilder,
    type_type: TypeBuilder,
    method_params: NamedRule,
    typedef_members: NamedRule)
  =>
    _context = context
    _trivia = trivia
    _token = token
    _keyword = keyword
    _operator = operator
    _literal = literal
    _type_type = type_type

    _method_params = method_params
    _typedef_members = typedef_members

    _build_annotation()
    _build_expression()

  fun ref _build_annotation() =>
    let bs = _token(ast.Tokens.backslash())
    let comma = _token(ast.Tokens.comma())
    let id = _token.identifier

    annotation.set_body(
      Conj(
        [ bs
          id
          Star(Conj([ comma; id ]))
          bs ],
        _ExpActions~_annotation()))

  fun ref _build_expression() =>
    let call_arg_named: NamedRule = NamedRule("a named argument")
    let call_args_named: NamedRule = NamedRule("named arguments")
    let call_args_pos: NamedRule = NamedRule("positional arguments")
    let call_args: NamedRule = NamedRule("a positional argument")
    let exp_array: NamedRule = NamedRule("an array literal")
    let exp_assignment: NamedRule = NamedRule("an assignment")
    let exp_atom: NamedRule = NamedRule("an atomic expression")
    let exp_cond: NamedRule = NamedRule("an if condition")
    let exp_consume: NamedRule = NamedRule("a consume expression")
    let exp_decl: NamedRule = NamedRule("a binding declaration")
    let exp_ffi: NamedRule = NamedRule("an FFI call")
    let exp_for: NamedRule = NamedRule("a for loop")
    let exp_hash: NamedRule = NamedRule("a compile-time expression")
    let exp_if: NamedRule = NamedRule("an if expression")
    let exp_ifdef: NamedRule = NamedRule("an ifdef expression")
    let exp_iftype: NamedRule = NamedRule("an iftype expression")
    let exp_jump: NamedRule = NamedRule("a jump expression")
    let exp_lambda: NamedRule = NamedRule("a lambda literal")
    let exp_match: NamedRule = NamedRule("a match expression")
    let exp_object: NamedRule = NamedRule("an object literal")
    let exp_parens: NamedRule = NamedRule("a parenthesized expression")
    let exp_postfix: NamedRule = NamedRule("a postfix expression")
    let exp_prefix: NamedRule = NamedRule("a prefix expression")
    let exp_recover: NamedRule = NamedRule("a recover expression")
    let exp_repeat: NamedRule = NamedRule("a repeat loop")
    let exp_term: NamedRule = NamedRule("a term")
    let exp_try: NamedRule = NamedRule("a try expression")
    let exp_tuple: NamedRule = NamedRule("a tuple literal")
    let exp_while: NamedRule = NamedRule("a while loop")
    let exp_with: NamedRule = NamedRule("a with expression")
    let match_case: NamedRule = NamedRule("a match case")
    let match_pattern: NamedRule = NamedRule("a match pattern")
    let with_elem: NamedRule = NamedRule("a with element")

    let amp = _token(ast.Tokens.amp())
    let arrow = _token(ast.Tokens.arrow())
    let at = _token(ast.Tokens.at())
    let bar = _token(ast.Tokens.bar())
    let binary_op = _operator.binary_op
    let ccurly = _token(ast.Tokens.close_curly())
    let colon = _token(ast.Tokens.colon())
    let comma = _token(ast.Tokens.comma())
    let cparen = _token(ast.Tokens.close_paren())
    let csquare = _token(ast.Tokens.close_square())
    let dot = _token(ast.Tokens.dot())
    let equals = _token(ast.Tokens.equals())
    let equal_arrow = _token(ast.Tokens.equal_arrow())
    let hash = _token(ast.Tokens.hash())
    let id = _token.identifier
    let kwd = _keyword.kwd
    let kwd_as = _keyword(ast.Keywords.kwd_as())
    let kwd_break = _keyword(ast.Keywords.kwd_break())
    let kwd_cap = _keyword.cap
    let kwd_compile_error = _keyword(ast.Keywords.kwd_compile_error())
    let kwd_compile_intrinsic = _keyword(ast.Keywords.kwd_compile_intrinsic())
    let kwd_consume = _keyword(ast.Keywords.kwd_consume())
    let kwd_continue = _keyword(ast.Keywords.kwd_continue())
    let kwd_do = _keyword(ast.Keywords.kwd_do())
    let kwd_else = _keyword(ast.Keywords.kwd_else())
    let kwd_elseif = _keyword(ast.Keywords.kwd_elseif())
    let kwd_embed = _keyword(ast.Keywords.kwd_embed())
    let kwd_end = _keyword(ast.Keywords.kwd_end())
    let kwd_error = _keyword(ast.Keywords.kwd_error())
    let kwd_for = _keyword(ast.Keywords.kwd_for())
    let kwd_if = _keyword(ast.Keywords.kwd_if())
    let kwd_ifdef = _keyword(ast.Keywords.kwd_ifdef())
    let kwd_iftype = _keyword(ast.Keywords.kwd_iftype())
    let kwd_in = _keyword(ast.Keywords.kwd_in())
    let kwd_is = _keyword(ast.Keywords.kwd_is())
    let kwd_let = _keyword(ast.Keywords.kwd_let())
    let kwd_loc = _keyword(ast.Keywords.kwd_loc())
    let kwd_match = _keyword(ast.Keywords.kwd_match())
    let kwd_object = _keyword(ast.Keywords.kwd_object())
    let kwd_recover = _keyword(ast.Keywords.kwd_recover())
    let kwd_repeat = _keyword(ast.Keywords.kwd_repeat())
    let kwd_return = _keyword(ast.Keywords.kwd_return())
    let kwd_then = _keyword(ast.Keywords.kwd_then())
    let kwd_this = _keyword(ast.Keywords.kwd_this())
    let kwd_try = _keyword(ast.Keywords.kwd_try())
    let kwd_until = _keyword(ast.Keywords.kwd_until())
    let kwd_var = _keyword(ast.Keywords.kwd_var())
    let kwd_where = _keyword(ast.Keywords.kwd_where())
    let kwd_while = _keyword(ast.Keywords.kwd_while())
    let kwd_with = _keyword(ast.Keywords.kwd_with())
    let literal = _literal.literal
    let literal_string = _literal.string
    let not_kwd = _keyword.not_kwd
    let ocurly = _token(ast.Tokens.open_curly())
    let oparen = _token(ast.Tokens.open_paren())
    let osquare = _token(ast.Tokens.open_square())
    let postfix_op = _operator.postfix_op
    let prefix_op = _operator.prefix_op
    let ques = _token(ast.Tokens.ques())
    let semicolon = _token(ast.Tokens.semicolon())
    let subtype = _token(ast.Tokens.subtype())
    let trivia = _trivia.trivia
    let type_args = _type_type.args
    let type_arrow = _type_type.arrow
    let type_params = _type_type.params

    // seq <= annotation? item (';'? item)*
    let seq_ann = Variable("seq_ann")
    let seq_body = Variable("seq_body")
    seq.set_body(
      Conj(
        [ Bind(seq_ann, Ques(annotation))
          Bind(
            seq_body,
            Conj(
              [ item
                Star(Conj([ Ques(semicolon); item ]))
              ]))
        ],
        _ExpActions~_seq(seq_ann, seq_body)))

    // item <= assignment / jump / infix
    item.set_body(
      Disj(
        [ exp_assignment
          exp_jump
          infix ]))

    // assignment <= (infix '=' assignment) / infix
    let ass_lhs = Variable("ass_lhs")
    let ass_op = Variable("ass_op")
    let ass_rhs = Variable("ass_rhs")
    exp_assignment.set_body(
      Disj(
        [ Conj(
            [ Bind(ass_lhs, infix)
              Bind(ass_op, equals)
              Bind(ass_rhs, exp_assignment) ],
            _ExpActions~_binop(ass_lhs, ass_op, ass_rhs, None))
        infix ]))

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
    infix.set_body(
      Disj(
        [ Disj(
            [ Conj(
                [ Bind(infix_lhs, exp_term)
                  Bind(infix_op, kwd_as)
                  Bind(infix_rhs, type_arrow) ])
              Conj(
                [ Bind(infix_lhs, exp_term)
                  Bind(infix_op, kwd_is)
                  Bind(infix_rhs, infix) ])
              Conj(
                [ Bind(infix_lhs, exp_term)
                  Bind(infix_op, binary_op)
                  Ques(Bind(infix_partial, ques))
                  Bind(infix_rhs, infix) ])
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

    // if <= 'if' cond ('elseif' cond)* ('else' seq)? 'end'
    let if_firstif = Variable("if_firstif")
    let if_elseifs = Variable("if_elseifs")
    let if_else_block = Variable("if_else_block")
    exp_if.set_body(
      Conj(
        [ kwd_if
          Bind(if_firstif, exp_cond)
          Bind(if_elseifs, Star(Conj([ kwd_elseif; exp_cond ])))
          Ques(Conj([ kwd_else; Bind(if_else_block, seq) ]))
          kwd_end ],
        _ExpActions~_if(if_firstif, if_elseifs, if_else_block)))

    // cond <= seq 'then' seq
    let cond_if_true = Variable("cond_if_true")
    let cond_then_block = Variable("cond_then_block")
    exp_cond.set_body(
      Conj(
        [ Bind(cond_if_true, seq)
          kwd_then
          Bind(cond_then_block, seq) ],
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
                Bind(ifdef_else_block, seq) ]))
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
                Bind(iftype_then_block, seq) ],
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
                  Bind(iftype_then_block, seq) ],
                _ExpActions~_iftype_cond(
                  iftype_if_true,
                  iftype_lhs,
                  iftype_op,
                  iftype_rhs,
                  iftype_then_block))))
          Ques(
            Conj(
              [ kwd_else
                Bind(iftype_else_block, seq) ]))
          kwd_end ],
        _ExpActions~_iftype(
          iftype_firstif, iftype_elseifs, iftype_else_block)))

    // match <= 'match' match_case+ ('else' seq)? 'end'
    let match_exp = Variable("match_exp")
    let match_cases = Variable("match_cases")
    let match_else_block = Variable("match_else_block")
    exp_match.set_body(
      Conj(
        [ kwd_match
          Bind(match_exp, seq)
          Bind(match_cases, Plus(match_case))
          Ques(Conj([ kwd_else; Bind(match_else_block, seq) ]))
          kwd_end ]),
      _ExpActions~_match(match_exp, match_cases, match_else_block))

    // match_pattern <= '|' item ('if' seq)?
    let match_pattern_pattern = Variable("match_pattern_pattern")
    let match_pattern_condition = Variable("match_pattern_condition")
    match_pattern.set_body(
      Conj(
        [ bar
          Bind(
            match_pattern_pattern,
            Disj([ exp_decl; exp_prefix; exp_hash ]))
          Ques(Conj([ kwd_if; Bind(match_pattern_condition, seq) ]))
        ]),
      _ExpActions~_match_pattern(
        match_pattern_pattern, match_pattern_condition))

    // match_case <= match_case_pattern+ '=>' seq
    let match_case_patterns = Variable("match_case_patterns")
    let match_case_body = Variable("match_case_body")
    match_case.set_body(
      Conj(
        [ Bind(match_case_patterns, Star(match_pattern, 1))
          equal_arrow
          Bind(match_case_body, seq)
        ]),
      _ExpActions~_match_case(match_case_patterns, match_case_body))

    // while <= 'while' seq 'do' seq ('else' seq)? 'end'
    let while_cond = Variable("while_cond")
    let while_body = Variable("while_body")
    let while_else_block = Variable("while_else_block")
    exp_while.set_body(
      Conj(
        [ kwd_while
          Bind(while_cond, seq)
          kwd_do
          Bind(while_body, seq)
          Ques(Conj([ kwd_else; Bind(while_else_block, seq) ]))
          kwd_end ]),
      _ExpActions~_while(while_cond, while_body, while_else_block))

    // repeat <= 'repeat' seq 'until' seq ('else' seq)? 'end'
    let repeat_body = Variable("repeat_body")
    let repeat_cond = Variable("repeat_cond")
    let repeat_else_block = Variable("repeat_else_block")
    exp_repeat.set_body(
      Conj(
        [ kwd_repeat
          Bind(repeat_body, seq)
          kwd_until
          Bind(repeat_cond, seq)
          Ques(Conj([ kwd_else; Bind(repeat_else_block, seq) ]))
          kwd_end ]),
      _ExpActions~_repeat(repeat_body, repeat_cond, repeat_else_block))

    // for <= 'for' (id / '(' id (',' id)* ')') 'in' seq 'do'
    //   seq ('else' seq)?
    // 'end'
    let for_ids = Variable("for_ids")
    let for_seq = Variable("for_seq")
    let for_body = Variable("for_body")
    let for_else_block = Variable("for_else_block")
    exp_for.set_body(
      Conj(
        [ kwd_for
          Bind(for_ids, tuple_pattern)
          kwd_in
          Bind(for_seq, seq)
          kwd_do
          Bind(for_body, seq)
          Ques(Conj([ kwd_else; Bind(for_else_block, seq)]))
          kwd_end ]),
      _ExpActions~_for(for_ids, for_seq, for_body, for_else_block))

    // tuple_pattern <= id / '(' tuple_pattern (',' tuple_pattern)* ')'
    tuple_pattern.set_body(
      Disj(
        [ id
          Conj(
            [ oparen
              tuple_pattern
              Star(Conj([ comma; tuple_pattern ]))
              cparen ]) ]),
      _ExpActions~_tuple_pattern())

    // with <= 'with' with_elem (',' with_elem)*
    //         'do' seq ('else' seq)? 'end'
    let with_elems = Variable("with_elems")
    let with_body = Variable("with_body")
    exp_with.set_body(
      Conj(
        [ kwd_with
          Bind(with_elems,
            Conj([ with_elem; Star(Conj([ comma; with_elem ])) ]))
          kwd_do
          Bind(with_body, seq)
          kwd_end ]),
      _ExpActions~_with(with_elems, with_body))

    // with_elem <= (id / ('(' id (',' id)*)) '=' seq
    let with_elem_pattern = Variable("with_elem_pattern")
    let with_elem_body = Variable("with_elem_body")
    with_elem.set_body(
      Conj(
        [ Bind(with_elem_pattern, tuple_pattern)
          equals
          Bind(with_elem_body, seq) ]),
      _ExpActions~_with_elem(with_elem_pattern, with_elem_body))

    // try <= 'try' seq ('else' seq)? 'end'
    let try_body = Variable("try_body")
    let try_else_block = Variable("try_else_block")
    exp_try.set_body(
      Conj(
        [ kwd_try
          Bind(try_body, Ques(seq))
          Ques(Conj([ kwd_else; Bind(try_else_block, seq) ]))
          kwd_end ]),
      _ExpActions~_try(try_body, try_else_block))

    // recover <= 'recover' cap? seq 'end'
    let recover_cap = Variable("recover_cap")
    let recover_body = Variable("recover_body")
    exp_recover.set_body(
      Conj(
        [ kwd_recover
          Ques(Bind(recover_cap, kwd_cap))
          Bind(recover_body, seq)
          kwd_end ]),
      _ExpActions~_recover(recover_cap, recover_body))

    // consume <= 'consume' cap? term
    let consume_cap = Variable("consume_cap")
    let consume_body = Variable("consume_body")
    exp_consume.set_body(
      Conj(
        [ kwd_consume
          Ques(Bind(consume_cap, kwd_cap))
          Bind(consume_body, exp_term) ]),
      _ExpActions~_consume(consume_cap, consume_body))

    // decl <= ('var' / 'let' / 'embed') id (':' type_type)?
    let decl_kind = Variable("decl_kind")
    let decl_identifier = Variable("decl_identifier")
    let decl_type = Variable("decl_type")
    exp_decl.set_body(
      Conj(
        [ Bind(decl_kind, Disj([ kwd_var; kwd_let; kwd_embed ]))
          Bind(decl_identifier, id)
          Ques(
            Conj(
              [ colon
                Bind(decl_type, type_arrow) ])) ]),
      _ExpActions~_decl(decl_kind, decl_identifier, decl_type))

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
      Disj(
        [ exp_tuple
          exp_parens
          exp_array
          exp_lambda
          exp_ffi
          exp_object
          Conj(
            [ Bind(atom_body,
                Disj([ kwd_loc; kwd_this; literal; Conj([ not_kwd; id ]) ])) ],
            _ExpActions~_atom(atom_body))
        ]))

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

    // call_args_pos <= seq (',' seq)*
    call_args_pos.set_body(
      Conj([ seq; Star(Conj([ comma; seq ])) ]))

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

    // call_arg_named <= identifier '=' seq
    let call_arg_name = Variable("call_arg_named_name")
    let call_arg_op = Variable("call_arg_named_op")
    let call_arg_rhs = Variable("call_arg_named_rhs")
    call_arg_named.set_body(
      Conj(
        [ Bind(call_arg_name, id)
          Bind(call_arg_op, equals)
          Bind(call_arg_rhs, seq) ]),
      _ExpActions~_binop(
          call_arg_name, call_arg_op, call_arg_rhs, None))

    // tuple <= '(' seq (',' seq)+ ')'
    let tuple_seqs = Variable("tuple_seqs")
    exp_tuple.set_body(
      Conj(
        [ oparen
          Bind(tuple_seqs, Conj([ seq; Plus(Conj([ comma; seq ])) ]))
          cparen ]),
      _ExpActions~_tuple(tuple_seqs))

    // parens <= '(' seq ')'
    let parens_body = Variable("parens_body")
    exp_parens.set_body(
      Conj(
        [ oparen
          Bind(parens_body, seq)
          cparen ]),
      _ExpActions~_atom(parens_body))

    // lambda
    let lambda_bare = Variable("lambda_bare")
    let lambda_ann = Variable("lambda_ann")
    let lambda_this_cap = Variable("lambda_this_cap")
    let lambda_id = Variable("lambda_id")
    let lambda_type_params = Variable("lambda_type_params")
    let lambda_params = Variable("lambda_params")
    let lambda_captures = Variable("lambda_captures")
    let lambda_ret_type = Variable("lambda_ret_type")
    let lambda_partial = Variable("lambda_partial")
    let lambda_body = Variable("lambda_body")
    let lambda_ref_cap = Variable("lambda_ref_cap")
    exp_lambda.set_body(
      Conj(
        [ Ques(Bind(lambda_bare, at))
          ocurly
          Ques(Bind(lambda_ann, annotation))
          Ques(Bind(lambda_this_cap, kwd_cap))
          Ques(Bind(lambda_id, id))
          Ques(Bind(lambda_type_params, type_params))
          oparen
          Ques(Bind(lambda_params, _method_params))
          cparen
          Ques(Conj([ oparen; Bind(lambda_captures, _method_params); cparen ]))
          Ques(Conj([ colon; Bind(lambda_ret_type, type_arrow) ]))
          Ques(Bind(lambda_partial, ques))
          equal_arrow
          Bind(lambda_body, seq)
          ccurly
          Ques(Bind(lambda_ref_cap, kwd_cap)) ]),
      _ExpActions~_lambda(
        lambda_bare,
        lambda_ann,
        lambda_this_cap,
        lambda_id,
        lambda_type_params,
        lambda_params,
        lambda_captures,
        lambda_ret_type,
        lambda_partial,
        lambda_body,
        lambda_ref_cap))

    // array <= '[' ('as' type_arrow ':') seq ']'
    let array_type = Variable("array_type")
    let array_body = Variable("array_body")
    exp_array.set_body(
      Conj(
        [ osquare
          Ques(Conj([ kwd_as; Bind(array_type, type_arrow); colon ]))
          Ques(Bind(array_body, seq))
          csquare ]),
      _ExpActions~_array(array_type, array_body))

    // ffi <= '@' (id / string) type_args? call_args '?'?
    let ffi_identifier = Variable("ffi_identifier")
    let ffi_type_args = Variable("ffi_type_args")
    let ffi_call_args = Variable("ffi_call_args")
    let ffi_partial = Variable("ffi_partial")
    exp_ffi.set_body(
      Conj(
        [ at
          Bind(ffi_identifier, Disj([ id; literal_string ]))
          Bind(ffi_type_args, Ques(type_args))
          Bind(ffi_call_args, call_args)
          Bind(ffi_partial, Ques(ques)) ]),
      _ExpActions~_ffi(
        ffi_identifier, ffi_type_args, ffi_call_args, ffi_partial))

    // object <=
    let obj_ann = Variable("obj_ann")
    let obj_cap = Variable("obj_cap")
    let obj_type = Variable("obj_type")
    let obj_members = Variable("obj_members")
    exp_object.set_body(
      Conj(
        [ kwd_object
          Ques(Bind(obj_ann, annotation))
          Ques(Bind(obj_cap, kwd_cap))
          Ques(Conj([ kwd_is; Bind(obj_type, type_arrow) ]))
          Bind(obj_members, _typedef_members)
          Disj(
            [ kwd_end
              Error(ErrorMsg.exp_object_unterminated())
            ])
        ]),
      _ExpActions~_object(obj_ann, obj_cap, obj_type, obj_members))
