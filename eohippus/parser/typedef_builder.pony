use ".."
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
  let typedef_alias: NamedRule = NamedRule("a type alias")
  let typedef_class: NamedRule = NamedRule("a type definition")

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
    _build_typedef_alias()
    _build_typedef_class()

  fun error_section(allowed: ReadSeq[NamedRule box], message: String)
    : RuleNode
  =>
    let eol = _trivia.eol
    let dol = _trivia.dol
    let eof = _trivia.eof

    NamedRule(
      "Error_Section",
      Conj(
        [ Neg(Disj([ Disj(allowed); Look(eof) ]))
          Plus(Conj(
            [ Neg(Disj([ dol; Look(eof) ]))
              Disj(
                [ eol
                  Single(
                    [],
                    {(d, r, c, b) =>
                      let value = ast.NodeWith[ast.Span](
                        _Build.info(d, r), c, ast.Span)
                      (value, b)
                    }) ]) ]))
          Disj([ dol; Look(eof) ]) ],
        {(d, r, c, b) =>
          let new_children: Array[ast.Node] trn = Array[ast.Node]
          var in_span = false
          var span_start = r.start
          var span_next = r.next
          for child in c.values() do
            match child
            | let span: ast.NodeWith[ast.Span] =>
              if in_span then
                try span_next = span.src_info().next as Loc end
              else
                try
                  span_start = span.src_info().start as Loc
                  span_next = span.src_info().next as Loc
                end
                in_span = true
              end
            else
              if in_span then
                new_children.push(ast.NodeWith[ast.Span](
                  ast.SrcInfo(d.locator, span_start, span_next), [], ast.Span))
              end
              new_children.push(child)
              in_span = false
            end
          end
          if in_span then
            new_children.push(ast.NodeWith[ast.Span](
              ast.SrcInfo(d.locator, span_start, span_next), [], ast.Span))
          end

          let value = ast.NodeWith[ast.ErrorSection](
            _Build.info(d, r), consume new_children, ast.ErrorSection(message))
          (value, b)
        }))

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
    method_params.set_body(
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
    let kwd_end = _keyword(ast.Keywords.kwd_end())
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
    let method_mparams = Variable("method_mparams")
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
          Ques(Bind(method_mparams, method_params))
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
        method_mparams,
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
        [ Look(Disj([ field; method ]))
          Bind(
            members_fields,
            Star(
              Disj(
                [ field
                  error_section(
                    [ field; method; kwd_end; typedef ],
                    ErrorMsg.src_file_expected_field_or_method())
                ])))
          Bind(
            members_methods,
            Star(
              Disj(
                [ method
                  error_section(
                    [ method; kwd_end; typedef ],
                    ErrorMsg.src_file_expected_method())
                ])))
        ]),
      _TypedefActions~_members(members_fields, members_methods))

  fun ref _build_typedef() =>
    typedef.set_body(
      Disj(
        [ typedef_primitive
          typedef_alias
          typedef_class
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

  fun ref _build_typedef_alias() =>
    let kwd_type = _keyword(ast.Keywords.kwd_type())
    let kwd_is = _keyword(ast.Keywords.kwd_is())

    let alias_id = Variable("alias_id")
    let alias_tparams = Variable("alias_tparams")
    let alias_type = Variable("alias_type")
    let alias_doc_string = Variable("alias_doc_string")
    typedef_alias.set_body(
      Conj(
        [ kwd_type
          Bind(alias_id, _token.identifier)
          Ques(Bind(alias_tparams, _type_type.params))
          kwd_is
          Bind(alias_type, _type_type.arrow)
          Ques(Bind(alias_doc_string, doc_string))
        ]),
      _TypedefActions~_alias(
        alias_id, alias_tparams, alias_type, alias_doc_string))

  fun ref _build_typedef_class() =>
    let at = _token(ast.Tokens.at())
    let kwd_actor = _keyword(ast.Keywords.kwd_actor())
    let kwd_class = _keyword(ast.Keywords.kwd_class())
    let kwd_interface = _keyword(ast.Keywords.kwd_interface())
    let kwd_is = _keyword(ast.Keywords.kwd_is())
    let kwd_struct = _keyword(ast.Keywords.kwd_struct())
    let kwd_trait = _keyword(ast.Keywords.kwd_trait())

    let class_kind = Variable("class_kind")
    let class_ann = Variable("class_ann")
    let class_raw = Variable("class_raw")
    let class_cap = Variable("class_cap")
    let class_id = Variable("class_id")
    let class_tparams = Variable("class_tparams")
    let class_constraint = Variable("class_constraint")
    let class_doc_string = Variable("class_doc_string")
    let class_members = Variable("class_members")

    typedef_class.set_body(
      Conj(
        [ Bind(
            class_kind,
            Disj(
              [ kwd_interface
                kwd_trait
                kwd_struct
                kwd_class
                kwd_actor
              ]))
          Ques(Bind(class_ann, _expression.annotation))
          Ques(Bind(class_raw, at))
          Ques(Bind(class_cap, _keyword.cap))
          Bind(class_id, _token.identifier)
          Ques(Bind(class_tparams, _type_type.params))
          Ques(Bind(class_constraint, Conj([ kwd_is; _type_type.arrow ])))
          Ques(Bind(class_doc_string, doc_string))
          Ques(Bind(class_members, members))
        ]),
      _TypedefActions~_class(
        class_kind,
        class_ann,
        class_raw,
        class_cap,
        class_id,
        class_tparams,
        class_constraint,
        class_doc_string,
        class_members))
