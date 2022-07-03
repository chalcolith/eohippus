use ast = "../ast"
use ".."

class _TypedefBuilder
  let _trivia: _TriviaBuilder
  let _token: _TokenBuilder
  let _expression: _ExpressionBuilder
  let _member: _MemberBuilder

  var _typedef: (NamedRule | None) = None
  var _td_primitive: (NamedRule | None) = None

  new create(trivia: _TriviaBuilder, token: _TokenBuilder,
    expression: _ExpressionBuilder, member: _MemberBuilder)
  =>
    _trivia = trivia
    _token = token
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
              typedef_primitive()
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
    match _td_primitive
    | let r: NamedRule => r
    else
      let t1 = Variable
      let id = Variable
      let ds = Variable
      let t2 = Variable

      let trivia0 = _trivia.trivia(0)
      let trivia1 = _trivia.trivia(1)
      let kwd_primitive = _token.kwd_primitive()
      let identifier = _expression.identifier()
      let docstring = _member.docstring()

      let primitive' =
        recover val
          NamedRule("Typedef_Primitive",
            Conj([
              Bind(t1, trivia0)
              kwd_primitive
              trivia1
              Bind(id, identifier)
              Bind(ds, docstring)
              Bind(t2, trivia0)
            ]),
            this~_typedef_primitive_action(t1, id, ds, t2))
        end
      _td_primitive = primitive'
      primitive'
    end

  fun tag _typedef_primitive_action(t1: Variable, id: Variable, ds: Variable,
    t2: Variable, r: Success, c: ast.NodeSeq[ast.Node], b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let t1': ast.Trivia =
      try
        b(t1)?._2(0)? as ast.Trivia
      else
        return (ast.ErrorSection(_Build.info(r), c,
          ErrorMsg.internal_ast_node_not_bound("Trivia")), b)
      end

    let id': ast.Identifier =
      try
        b(id)?._2(0)? as ast.Identifier
      else
        return (ast.ErrorSection(_Build.info(r), c,
          ErrorMsg.internal_ast_node_not_bound("Identifier")), b)
      end

    let ds': ast.NodeSeq[ast.Docstring] = _Build.docstrings(b, ds)

    let t2': ast.Trivia =
      try
        b(t2)?._2(0)? as ast.Trivia
      else
        return (ast.ErrorSection(_Build.info(r), c,
          ErrorMsg.internal_ast_node_not_bound("Trivia")), b)
      end

    (ast.TypedefPrimitive(_Build.info(r), t1', t2', ds', id'), b)
