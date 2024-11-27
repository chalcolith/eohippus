use ast = "../ast"

class TypeBuilder
  let _context: Context
  let _token: TokenBuilder
  let _keyword: KeywordBuilder

  let args: NamedRule = NamedRule("type arguments")
  let arrow: NamedRule = NamedRule("a type" where memoize' = true)
  let atom: NamedRule = NamedRule("a basic type")
  let infix: NamedRule = NamedRule("an algebraic type expression")
  let lambda: NamedRule = NamedRule("a lambda type")
  let nominal: NamedRule = NamedRule("a type name")
  let param: NamedRule = NamedRule("a type parameter")
  let params: NamedRule = NamedRule("type parameters")
  let tuple: NamedRule = NamedRule("a tuple type")

  new create(context: Context, token: TokenBuilder, keyword: KeywordBuilder) =>
    _context = context
    _token = token
    _keyword = keyword

    _build_type()

  fun ref _build_type() =>
    let amp = _token(ast.Tokens.amp())
    let tok_arrow = _token(ast.Tokens.arrow())
    let at = _token(ast.Tokens.at())
    let bang = _token(ast.Tokens.bang())
    let bar = _token(ast.Tokens.bar())
    let ccurly = _token(ast.Tokens.close_curly())
    let colon = _token(ast.Tokens.colon())
    let cparen = _token(ast.Tokens.close_paren())
    let csquare = _token(ast.Tokens.close_square())
    let comma = _token(ast.Tokens.comma())
    let dot = _token(ast.Tokens.dot())
    let equals = _token(ast.Tokens.equals())
    let hat = _token(ast.Tokens.hat())
    let id = _token.identifier
    let kwd_cap = _keyword.cap
    let kwd_gencap = _keyword.gencap
    let kwd_this = _keyword(ast.Keywords.kwd_this())
    let ocurly = _token(ast.Tokens.open_curly())
    let oparen = _token(ast.Tokens.open_paren())
    let osquare = _token(ast.Tokens.open_square())
    let ques = _token(ast.Tokens.ques())

    // type_args <= '[' type_arg (',' type_arg)* ']'
    args.set_body(
      Conj(
        [ osquare
          arrow
          Star(
            Conj(
              [ comma
                arrow ]))
          csquare
        ]),
        _TypeActions~_type_args())

    // type_params <= '[' type_param (',' type_param)* ']'
    params.set_body(
      Conj(
        [ osquare
          Conj(
            [ param
              Star(Conj([ comma; param ]))
            ])
          csquare
        ]),
        _TypeActions~_type_params())

    // type_param <= id (':' type_arrow)? ('=' type_arrow)?
    let param_name = Variable("param_name")
    let param_type_constraint = Variable("param_type_constraint")
    let param_type_initializer = Variable("param_type_initializer")
    param.set_body(
      Disj(
        [ Conj(
            [ Bind(param_type_constraint, arrow)
              Neg(Disj([ colon; equals ]))
            ])
          Conj(
            [ Bind(param_name, id)
              Ques(
                Conj(
                  [ colon; Bind(param_type_constraint, arrow) ]))
              Ques(
                Conj(
                  [ equals; Bind(param_type_initializer, arrow) ]))
            ])
        ]),
      _TypeActions~_type_param(
        param_name, param_type_constraint, param_type_initializer))

    // type <= atom_type (arrow type)?
    let arrow_lhs = Variable("arrow_lhs")
    let arrow_rhs = Variable("arrow_rhs")
    arrow.set_body(
      Conj(
        [ Bind(arrow_lhs, atom)
          Ques(
            Conj(
              [ tok_arrow
                Bind(arrow_rhs, arrow)
              ]))
        ]),
        _TypeActions~_type_arrow(arrow_lhs, arrow_rhs))

    // atom_type <= 'this' / cap / '(' tuple_type ')' / '(' infix_type ')' /
    //              nominal_type / lambda_type
    let atom_body = Variable("atom_body")
    atom.set_body(
      Disj(
        [ Bind(atom_body, kwd_this)
          Bind(atom_body, kwd_cap)
          Bind(atom_body, tuple)
          Conj([ oparen; Bind(atom_body, infix); cparen ])
          Bind(atom_body, nominal)
          Bind(atom_body, lambda)
        ]),
        _TypeActions~_type_atom(atom_body))

    // tuple_type <= infix_type (',' infix_type)+
    tuple.set_body(
      Conj(
        [ oparen
          arrow
          Plus(Conj([ comma; arrow ]))
          cparen
        ]),
        _TypeActions~_type_tuple())

    // infix_type <=
    let infix_types = Variable("infix_types")
    let infix_op = Variable("infix_op")
    infix.set_body(
      Disj(
        [ Bind(infix_types,
            Conj(
              [ arrow
                Plus(Conj([ Bind(infix_op, amp); arrow ]))
              ]))
          Bind(infix_types,
            Conj(
              [ arrow
                Plus(Conj([ Bind(infix_op, bar); arrow ]))
              ]))
        ]),
        _TypeActions~_type_infix(infix_types, infix_op))

    // nominal_type <= identifier ('.' identifier)? type_params
    //                 (cap / gencap)? ('^' / '!')?
    let nominal_lhs = Variable("nominal_lhs")
    let nominal_rhs = Variable("nominal_rhs")
    let nominal_params = Variable("nominal_params")
    let nominal_cap = Variable("nominal_cap")
    let nominal_eph = Variable("nominal_eph")
    nominal.set_body(
      Conj(
        [ Bind(nominal_lhs, id)
          Ques(Conj([ dot; Bind(nominal_rhs, id) ]))
          Bind(nominal_params, Ques(params))
          Bind(nominal_cap, Ques(Disj([ kwd_cap; kwd_gencap ])))
          Bind(nominal_eph, Ques(Disj([ hat; bang ])))
        ]),
        _TypeActions~_type_nominal(
          nominal_lhs,
          nominal_rhs,
          nominal_params,
          nominal_cap,
          nominal_eph))

    // lambda_type <= '@'? '{' cap? id? type_params? '('
    //                (type_arrow (',' type_arrow)*)? ')' (':' type_arrow)?
    //                '?'? '}' (cap / gencap)? ('^' / '!')?
    let lambda_bare = Variable("lambda_bare")
    let lambda_this_cap = Variable("lambda_this_cap")
    let lambda_name = Variable("lambda_name")
    let lambda_type_params = Variable("lambda_type_params")
    let lambda_param_types = Variable("lambda_param_types")
    let lambda_return_type = Variable("lambda_return_type")
    let lambda_partial = Variable("lambda_partial")
    let lambda_ref_cap = Variable("lambda_ref_cap")
    let lambda_ref_eph = Variable("lambda_ref_eph")
    lambda.set_body(
      Conj(
        [ Bind(lambda_bare, Ques(at))
          ocurly
          Bind(lambda_this_cap, Ques(kwd_cap))
          Bind(lambda_name, Ques(id))
          Bind(lambda_type_params, Ques(params))
          oparen
          Bind(lambda_param_types, Ques(
            Conj(
              [ arrow
                Star(Conj([comma; arrow]))
              ])))
          cparen
          Ques(Conj([colon; Bind(lambda_return_type, arrow)]))
          Bind(lambda_partial, Ques(ques))
          ccurly
          Bind(lambda_ref_cap, Ques(Disj([ kwd_cap; kwd_gencap ])))
          Bind(lambda_ref_eph, Ques(Disj([ hat; bang ])))
        ]),
        _TypeActions~_type_lambda(
          lambda_bare,
          lambda_this_cap,
          lambda_name,
          lambda_type_params,
          lambda_param_types,
          lambda_return_type,
          lambda_partial,
          lambda_ref_cap,
          lambda_ref_eph))
