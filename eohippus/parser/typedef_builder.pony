use ast = "../ast"
use ".."

class TypedefBuilder
  let _trivia: TriviaBuilder
  let _token: TokenBuilder
  let _keyword: KeywordBuilder
  let _expression: ExpressionBuilder
  let _member: MemberBuilder

  var _typedef: (NamedRule | None) = None
  var _td_primitive: (NamedRule | None) = None

  new create(trivia: TriviaBuilder, token: TokenBuilder,
    keyword: KeywordBuilder, expression: ExpressionBuilder,
    member: MemberBuilder)
  =>
    _trivia = trivia
    _token = token
    _keyword = keyword
    _expression = expression
    _member = member

  fun ref typedef() : NamedRule =>
    match _typedef
    | let r: NamedRule => r
    else
      let typedef' =
        recover val
          NamedRule("Typedef",
            Disj([
              td_primitive()
              // typedef_interface()
              // typedef_trait()
              // typedef_class()
              // typedef_actor()
              // typedef_struct()
              // typedef_is()
            ]))
        end
      _typedef = typedef'
      typedef'
    end

  fun ref td_primitive() : NamedRule =>
    match _td_primitive
    | let r: NamedRule => r
    else
      let id = Variable("id")
      let ds = Variable("ds")

      let kwd_primitive = _keyword.kwd_primitive()
      let identifier = _expression.identifier()
      let docstring = _member.docstring()

      let primitive' =
        recover val
          NamedRule("Typedef_Primitive",
            Conj([
              kwd_primitive
              Bind(id, identifier)
              Bind(ds, docstring)
            ]),
            this~_typedef_primitive_action(id, ds))
        end
      _td_primitive = primitive'
      primitive'
    end

  fun tag _typedef_primitive_action(id: Variable, ds: Variable,
    r: Success, c: ast.NodeSeq[ast.Node], b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let id': ast.Identifier =
      try
        _Build.value(b, id)? as ast.Identifier
      else
        return _Build.bind_error(r, c, b, "Identifier")
      end

    let ds': ast.NodeSeq[ast.Docstring] = _Build.docstrings(b, ds)

    (ast.TypedefPrimitive(_Build.info(r), ds', id'), b)
