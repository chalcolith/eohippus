use ast = "../ast"

class TypeBuilder
  let _context: Context
  let _token: TokenBuilder
  let _keyword: KeywordBuilder

  var _type: (NamedRule | None) = None

  new create(context: Context, token: TokenBuilder, keyword: KeywordBuilder) =>
    _context = context
    _token = token
    _keyword = keyword

  fun ref type_rule(): NamedRule =>
    match _type
    | let r: NamedRule => r
    else
      let amp = _token(ast.Tokens.amp())
      let arrow = _token(ast.Tokens.arrow())
      let bar = _token(ast.Tokens.bar())
      let comma = _token(ast.Tokens.comma())
      let cparen = _token(ast.Tokens.close_paren())
      let kwd_cap = _keyword.cap()
      let kwd_this = _keyword(ast.Keywords.kwd_this())
      let oparen = _token(ast.Tokens.open_paren())

      let type' =
        recover val
          let type_type = NamedRule("Type_Type", None)
          let atom_type = NamedRule("Type_Atom", None)
          let tuple_type = NamedRule("Type_Tuple", None)
          let infix_type = NamedRule("Type_Infix", None)
          let nominal_type = NamedRule("Type_Nominal", None)
          let bare_lambda_type = NamedRule("Type_BareLambda", None)
          let lambda_type = NamedRule("Type_Lambda", None)

          let lhs = Variable("lhs")
          let rhs = Variable("rhs")
          let op = Variable("op")

          type_type.set_body(
            Conj([
              Bind(lhs, atom_type)
              Ques(
                Conj([
                  arrow
                  Bind(rhs, type_type)
                ])
              )
            ]),
            _TypeActions~_type_type(lhs, rhs))

          atom_type.set_body(
            Disj([
              kwd_this
              kwd_cap
              Conj([ oparen; tuple_type; cparen ])
              Conj([ oparen; infix_type; cparen ])
              nominal_type
              bare_lambda_type
              lambda_type
            ]),
            {(r, c, b) => (ast.TypeAtom(_Build.info(r), c), b) })

          tuple_type.set_body(
            Conj([
              infix_type
              Plus(Conj([
                comma
                infix_type
              ]))
            ]),
            {(r, c, b) => (ast.TypeTuple(_Build.info(r), c), b) })

          infix_type.set_body(
            Conj([
              Bind(lhs, type_type)
              Bind(op, Disj([amp; bar]))
              Bind(rhs, infix_type)
            ]),
            _TypeActions~_type_infix(lhs, op, rhs))

          type_type
        end
      _type = type'
      type'
    end
