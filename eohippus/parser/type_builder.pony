use ast = "../ast"

class TypeBuilder
  let _context: Context

  let _token: TokenBuilder
  let _keyword: KeywordBuilder

  var _type_arrow: (NamedRule | None) = None
  var _type_atom: (NamedRule | None) = None
  var _type_tuple: (NamedRule | None) = None
  var _type_infix: (NamedRule | None) = None
  var _type_nominal: (NamedRule | None) = None
  var _type_lambda: (NamedRule | None) = None
  var _type_args: (NamedRule | None) = None

  new create(context: Context, token: TokenBuilder, keyword: KeywordBuilder) =>
    _context = context
    _token = token
    _keyword = keyword

  fun ref arrow(): NamedRule =>
    match _type_arrow
    | let r: NamedRule =>
      r
    else
      _build_type()._1
    end

  fun ref atom(): NamedRule =>
    match _type_atom
    | let r: NamedRule =>
      r
    else
      _build_type()._2
    end

  fun ref tuple(): NamedRule =>
    match _type_tuple
    | let r: NamedRule =>
      r
    else
      _build_type()._3
    end

  fun ref infix(): NamedRule =>
    match _type_infix
    | let r: NamedRule =>
      r
    else
      _build_type()._4
    end

  fun ref nominal(): NamedRule =>
    match _type_atom
    | let r: NamedRule =>
      r
    else
      _build_type()._5
    end

  fun ref lambda(): NamedRule =>
    match _type_atom
    | let r: NamedRule =>
      r
    else
      _build_type()._6
    end

  fun ref args(): NamedRule =>
    match _type_args
    | let r: NamedRule =>
      r
    else
      _build_type()._7
    end

  fun ref _build_type()
    : ( NamedRule,
        NamedRule,
        NamedRule,
        NamedRule,
        NamedRule,
        NamedRule,
        NamedRule )
  =>
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
    let id = _token.identifier()
    let kwd_cap = _keyword.cap()
    let kwd_gencap = _keyword.gencap()
    let kwd_this = _keyword(ast.Keywords.kwd_this())
    let ocurly = _token(ast.Tokens.open_curly())
    let oparen = _token(ast.Tokens.open_paren())
    let osquare = _token(ast.Tokens.open_square())
    let ques = _token(ast.Tokens.ques())

    ( let type_arrow',
      let type_atom',
      let type_tuple',
      let type_infix',
      let type_nominal',
      let type_lambda',
      let type_args' ) =
      recover val
        let type_args = NamedRule("Type_Args", None)                        // x
        let type_arrow = NamedRule("Type_Arrow", None)                      // x
        let type_atom = NamedRule("Type_Atom", None)                        // x
        let type_infix = NamedRule("Type_Infix", None)                      // x
        let type_lambda = NamedRule("Type_Lambda", None)                    // x
        let type_nominal = NamedRule("Type_Nominal", None)                  // x
        let type_param = NamedRule("Type_Param", None)                      // x
        let type_params = NamedRule("Type_Params", None)                    // x
        let type_tuple = NamedRule("Type_Tuple", None)                      // x

        // type_args <= '[' type_arg (',' type_arg)* ']'
        type_args.set_body(
          Conj(
            [ osquare
              type_arrow
              Star(
                Conj(
                  [ comma
                    type_arrow ]))
              csquare ]),
            _TypeActions~_type_args())

        // type_params <= '[' type_param (',' type_param)* ']'
        type_params.set_body(
          Conj(
            [ osquare
              Conj(
                [ type_param
                  Star(Conj([ comma; type_param ])) ])
              csquare ]),
            _TypeActions~_type_params())

        // type_param <= id (':' type_arrow)? ('=' type_arrow)?
        let param_name = Variable("param_name")
        let param_type_constraint = Variable("param_type_constraint")
        let param_type_initializer = Variable("param_type_initializer")
        type_param.set_body(
          Disj(
            [ Conj(
                [ Bind(param_type_constraint, type_arrow)
                  Neg(Disj([ colon; equals ])) ])
              Conj(
                [ Bind(param_name, id)
                  Ques(Conj(
                    [ colon; Bind(param_type_constraint, type_arrow) ]))
                  Ques(Conj(
                    [ equals; Bind(param_type_initializer, type_arrow) ])) ])
            ]),
          _TypeActions~_type_param(
            param_name, param_type_constraint, param_type_initializer))

        // type <= atom_type (arrow type)?
        let arrow_lhs = Variable("arrow_lhs")
        let arrow_rhs = Variable("arrow_rhs")
        type_arrow.set_body(
          Conj(
            [ Bind(arrow_lhs, type_atom)
              Ques(
                Conj(
                  [ tok_arrow
                    Bind(arrow_rhs, type_arrow) ])) ]),
            _TypeActions~_type_arrow(arrow_lhs, arrow_rhs))

        // atom_type <= 'this' / cap / '(' tuple_type ')' / '(' infix_type ')' /
        //              nominal_type / lambda_type
        let atom_body = Variable("atom_body")
        type_atom.set_body(
          Disj(
            [ Bind(atom_body, kwd_this)
              Bind(atom_body, kwd_cap)
              Bind(atom_body, type_tuple)
              Conj([ oparen; Bind(atom_body, type_infix); cparen ])
              Bind(atom_body, type_nominal)
              Bind(atom_body, type_lambda) ]),
            _TypeActions~_type_atom(atom_body))

        // tuple_type <= infix_type (',' infix_type)+
        type_tuple.set_body(
          Conj(
            [ oparen
              type_arrow
              Plus(Conj([ comma; type_arrow ]))
              cparen ]),
            _TypeActions~_type_tuple())

        // infix_type <=
        let infix_types = Variable("infix_types")
        let infix_op = Variable("infix_op")
        type_infix.set_body(
          Disj(
            [ Bind(infix_types,
                Conj(
                  [ type_arrow
                    Plus(Conj([ Bind(infix_op, amp); type_arrow ])) ]))
              Bind(infix_types,
                Conj(
                  [ type_arrow
                    Plus(Conj([ Bind(infix_op, bar); type_arrow ])) ])) ],
            _TypeActions~_type_infix(infix_types, infix_op)))

        // nominal_type <= identifier ('.' identifier)? type_params
        //                 (cap / gencap)? ('^' / '!')?
        let nominal_lhs = Variable("nominal_lhs")
        let nominal_rhs = Variable("nominal_rhs")
        let nominal_params = Variable("nominal_params")
        let nominal_cap = Variable("nominal_cap")
        let nominal_eph = Variable("nominal_eph")
        type_nominal.set_body(
          Conj(
            [ Bind(nominal_lhs, id)
              Ques(Conj([ dot; Bind(nominal_rhs, id) ]))
              Bind(nominal_params, Ques(type_params))
              Bind(nominal_cap, Ques(Disj([ kwd_cap; kwd_gencap ])))
              Bind(nominal_eph, Ques(Disj([ hat; bang ]))) ]),
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
        type_lambda.set_body(
          Conj([
            Bind(lambda_bare, Ques(at))
            ocurly
            Bind(lambda_this_cap, Ques(kwd_cap))
            Bind(lambda_name, Ques(id))
            Bind(lambda_type_params, Ques(type_params))
            oparen
            Bind(lambda_param_types, Ques(
              Conj([
                type_arrow
                Star(Conj([comma; type_arrow]))
              ])))
            cparen
            Bind(lambda_return_type, Ques(Conj([colon; type_arrow])))
            Bind(lambda_partial, Ques(ques))
            ccurly
            Bind(lambda_ref_cap, Ques(Disj([kwd_cap; kwd_gencap])))
            Bind(lambda_ref_eph, Ques(Disj([hat; bang])))
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

        ( type_arrow,
          type_atom,
          type_tuple,
          type_infix,
          type_nominal,
          type_lambda,
          type_args )
      end

    _type_arrow = type_arrow'
    _type_atom = type_atom'
    _type_tuple = type_tuple'
    _type_infix = type_infix'
    _type_nominal = type_nominal'
    _type_lambda = type_lambda'
    _type_args = type_args'

    ( type_arrow',
      type_atom',
      type_tuple',
      type_infix',
      type_nominal',
      type_lambda',
      type_args' )
