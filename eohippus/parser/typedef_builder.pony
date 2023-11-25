use ast = "../ast"

class TypedefBuilder
  let _trivia: TriviaBuilder
  let _token: TokenBuilder
  let _keyword: KeywordBuilder
  let _expression: ExpressionBuilder
  let _member: MemberBuilder

  let typedef: NamedRule = NamedRule("a type definition")
  let typedef_primitive: NamedRule = NamedRule("a primitive type definition")

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

    _build_typedef()
    _build_typedef_primitive()

  fun ref _build_typedef() =>
    typedef.set_body(
      Disj(
        [ typedef_primitive
        ]))

  fun ref _build_typedef_primitive() =>
    let id = Variable("id")
    let ds = Variable("ds")

    typedef_primitive.set_body(
      Conj(
        [ _keyword(ast.Keywords.kwd_primitive())
          Bind(id, _token.identifier)
          Bind(ds, Ques(_member.doc_string))
        ]),
        recover this~_typedef_primitive_action(id, ds) end)

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
