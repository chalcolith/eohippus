use ast = "../ast"

class TypedefBuilder
  let _trivia: TriviaBuilder
  let _token: TokenBuilder
  let _keyword: KeywordBuilder
  let _literal: LiteralBuilder
  let _type_type: TypeBuilder
  let _expression: ExpressionBuilder

  let doc_string: NamedRule = NamedRule("a doc string")
  let params: NamedRule
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
    params = method_params'
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
    params.set_body(
      Conj([ method_param; Star(Conj([ comma; method_param ])) ]),
      _TypedefActions~_method_params())

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
    let at = _token(ast.Tokens.at())
    let colon = _token(ast.Tokens.colon())
    let cparen = _token(ast.Tokens.close_paren())
    let equal_arrow = _token(ast.Tokens.equal_arrow())
    let equals = _token(ast.Tokens.equals())
    let kwd_be = _keyword(ast.Keywords.kwd_be())
    let kwd_embed = _keyword(ast.Keywords.kwd_embed())
    let kwd_fun = _keyword(ast.Keywords.kwd_fun())
    let kwd_let = _keyword(ast.Keywords.kwd_let())
    let kwd_new = _keyword(ast.Keywords.kwd_new())
    let kwd_var = _keyword(ast.Keywords.kwd_var())
    let oparen = _token(ast.Tokens.open_paren())
    let ques = _token(ast.Tokens.ques())

    // field <= ('var' / 'let' / 'embed') id ':' type_arrow
    //          ('=' exp_infix)? doc_string?
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

    // method <= ('fun' / 'be' / 'new') annotation? (cap / '@')? id type_params?
    //           '(' method_params ')' (':' type_arrow)? '?'? doc_string?
    //           ('=>' exp_seq)?
    let method_kind = Variable("method_kind")
    let method_ann = Variable("method_ann")
    let method_cap = Variable("method_cap")
    let method_raw = Variable("method_raw")
    let method_id = Variable("method_id")
    let method_tparams = Variable("method_tparams")
    let method_params = Variable("method_params")
    let method_rtype = Variable("method_rtype")
    let method_partial = Variable("method_partial")
    let method_doc_string = Variable("method_doc_string")
    let method_body = Variable("method_body")
    method.set_body(
      Conj(
        [ Bind(method_kind, Disj([ kwd_fun; kwd_be; kwd_new ]))
          Ques(Bind(method_ann, _expression.annotation))
          Ques(Disj([ Bind(method_cap, _keyword.cap); Bind(method_raw, at) ]))
          Bind(method_id, _token.identifier)
          Ques(Bind(method_tparams, _type_type.params))
          oparen
          Ques(Bind(method_params, params))
          cparen
          Ques(Conj([ colon; Bind(method_rtype, _type_type.arrow) ]))
          Ques(Bind(method_partial, ques))
          Ques(Bind(method_doc_string, doc_string))
          Ques(Conj([ equal_arrow; Bind(method_body, _expression.seq) ]))
        ]),
      _TypedefActions~_method(
        method_kind,
        method_ann,
        method_cap,
        method_raw,
        method_id,
        method_tparams,
        method_params,
        method_rtype,
        method_partial,
        method_doc_string,
        method_body
      ))

    // members
    let members_fields = Variable("fields")
    let members_methods = Variable("methods")
    members.set_body(
      Conj(
        [ Bind(members_fields, Star(field))
          Bind(members_methods, Star(method))
        ]),
      _TypedefActions~_members(members_fields, members_methods))

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
      _TypedefActions~_primitive(id, ds))
