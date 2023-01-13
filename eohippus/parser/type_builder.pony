use ast = "../ast"

class TypeBuilder
  let _context: Context
  let _token: TokenBuilder

  var _type: (NamedRule | None) = None

  new create(context: Context, token: TokenBuilder) =>
    _context = context
    _token = token

  fun ref type_rule(): NamedRule =>
    match _type
    | let r: NamedRule => r
    else
      let arrow = _token(ast.Tokens.arrow())

      let type' =
        recover val
          let type_type = NamedRule("Type_Type", None)
          let atom_type = NamedRule("Type_Atom", None)

          let lhs = Variable("lhs")
          let rhs = Variable("rhs")

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

          type_type
        end
      _type = type'
      type'
    end
