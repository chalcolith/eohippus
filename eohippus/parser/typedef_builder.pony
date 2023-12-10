use ast = "../ast"

class TypedefBuilder
  let _trivia: TriviaBuilder
  let _token: TokenBuilder
  let _keyword: KeywordBuilder
  let _literal: LiteralBuilder
  let _type_type: TypeBuilder
  let _expression: ExpressionBuilder

  let doc_string: NamedRule = NamedRule("a doc string")
  let method_params: NamedRule
  let members: NamedRule
  let field: NamedRule = NamedRule("a field")
  let method: NamedRule = NamedRule("a method")
  let typedef: NamedRule = NamedRule("a type definition")
  let typedef_primitive: NamedRule = NamedRule("a primitive type definition")

  new create(
    trivia: TriviaBuilder,
    token: TokenBuilder,
    keyword: KeywordBuilder,
    literal: LiteralBuilder,
    type_type: TypeBuilder,
    expression: ExpressionBuilder,
    method_params': NamedRule,
    typedef_members': NamedRule)
  =>
    _trivia = trivia
    _token = token
    _keyword = keyword
    _literal = literal
    _type_type = type_type
    _expression = expression
    method_params = method_params'
    members = typedef_members'

    _build_doc_string()
    _build_method_params()
    _build_typedef_members()
    _build_typedef()
    _build_typedef_primitive()

  fun error_section(allowed: ReadSeq[NamedRule], message: String)
    : RuleNode
  =>
    let dol = _trivia.dol
    let eof = _trivia.eof

    NamedRule(
      "Error_Section",
      Conj(
        [ Neg(Disj([ Disj(allowed); eof ]))
          Plus(Conj([ Neg(Disj([ dol; eof ])); Single() ]))
          Disj([ dol; eof ]) ],
        {(d, r, c, b) =>
          let value = ast.NodeWith[ast.ErrorSection](
            _Build.info(d, r), c, ast.ErrorSection(message))
          (value, b) }))

  fun ref _build_doc_string() =>
    let s = Variable("s")
    doc_string.set_body(
      Bind(s, _literal.string),
      recover _TypedefActions~_doc_string(s) end)

  fun ref _build_method_params() =>
    let method_param = NamedRule("a method parameter")

    let colon = _token(ast.Tokens.colon())
    let comma = _token(ast.Tokens.comma())
    let equals = _token(ast.Tokens.equals())
    let id = _token.identifier

    // method_params <= (method_param (',' method_param)*)
    let method_params_params = Variable("method_params_params")
    method_params.set_body(
      Ques(
        Bind(
          method_params_params,
          Conj(
            [ method_param
              Star(Conj([ comma; method_param ])) ]))),
      _TypedefActions~_method_params(method_params_params))

    // method_param <= id (':' type_arrow)? ('=' infix)?
    let method_param_id = Variable("method_param_id")
    let method_param_constraint = Variable("method_param_constraint")
    let method_param_init = Variable("method_param_init")
    method_param.set_body(
      Conj(
        [ Bind(method_param_id, id)
          Ques(Conj(
            [ colon
              Bind(method_param_constraint, _type_type.arrow) ]))
          Ques(Conj([ equals; Bind(method_param_init, _expression.infix)])) ]),
      _TypedefActions~_method_param(
        method_param_id,
        method_param_constraint,
        method_param_init))

  fun ref _build_typedef_members() =>
    // field <= ('var' / 'let' / 'embed') id ':' type_arrow
    //          ('=' exp_infix)? doc_string?

    let colon = _token(ast.Tokens.colon())
    let equals = _token(ast.Tokens.equals())
    let kwd_var = _keyword(ast.Keywords.kwd_var())
    let kwd_let = _keyword(ast.Keywords.kwd_let())
    let kwd_embed = _keyword(ast.Keywords.kwd_embed())

    let field_kind = Variable("field_kind")
    let field_identifier = Variable("field_identifier")
    let field_type = Variable("field_type")
    let field_value = Variable("field_value")
    let field_doc_string = Variable("field_doc_string")
    field.set_body(
      Conj(
        [ Bind(field_kind, Disj([ kwd_var; kwd_let; kwd_embed ]))
          Bind(field_identifier, _token.identifier)
          Ques(Conj([ colon; Bind(field_type, _type_type.arrow) ]))
          Ques(Conj([ equals; Bind(field_value, _expression.infix) ]))
          Ques(Bind(field_doc_string, doc_string))
        ]),
      _TypedefActions~_field(
        field_kind,
        field_identifier,
        field_type,
        field_value,
        field_doc_string
      ))

    // members
    let fields = Variable("fields")
    let methods = Variable("methods")
    members.set_body(
      Conj(
        [ ]


      )
    )

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
          Bind(ds, Ques(doc_string))
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

    let value = ast.NodeWith[ast.Typedef](
      _Build.info(d, r), c, ast.TypedefPrimitive(id')
      where doc_strings' = ds')
    (value, b)
