use ast = "../ast"

class TypedefBuilder
  let _trivia: TriviaBuilder
  let _token: TokenBuilder
  let _keyword: KeywordBuilder
  let _expression: ExpressionBuilder
  let _member: MemberBuilder

  var _typedef: (NamedRule | None) = None
  var _typedef_primitive: (NamedRule | None) = None

  new create(
    trivia: TriviaBuilder,
    token: TokenBuilder,
    keyword: KeywordBuilder,
    expression: ExpressionBuilder,
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
            Disj(
              [ typedef_primitive()
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

  fun ref typedef_primitive() : NamedRule =>
    match _typedef_primitive
    | let r: NamedRule => r
    else
      let id = Variable("id")
      let ds = Variable("ds")

      let kwd_primitive = _keyword(ast.Keywords.kwd_primitive())
      let identifier = _token.identifier()
      let doc_string = _member.doc_string()

      let primitive' =
        recover val
          NamedRule("Typedef_Primitive",
            Conj(
              [ kwd_primitive
                Bind(id, identifier)
                Bind(ds, Ques(doc_string)) ]),
              this~_typedef_primitive_action(id, ds))
        end
      _typedef_primitive = primitive'
      primitive'
    end

  fun tag _typedef_primitive_action(
    id: Variable,
    ds: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let id': ast.NodeWith[ast.Identifier] =
      try
        _Build.value_with[ast.Identifier](b, id, r)?
      else
        return _Build.bind_error(d, r, c, b, "Identifier")
      end
    let ds' = _Build.values_with[ast.DocString](b, ds, r)

    let value = ast.NodeWith[ast.TypeDefPrimitive](
      _Build.info(d, r), c, ast.TypeDefPrimitive(id')
      where doc_strings' = ds')
    (value, b)
