use ast = "../ast"
use ".."

class MemberBuilder
  let _trivia: TriviaBuilder
  let _literal: LiteralBuilder

  let doc_string: NamedRule = NamedRule("a doc string")

  new create(trivia: TriviaBuilder, literal: LiteralBuilder) =>
    _trivia = trivia
    _literal = literal

    _build_doc_string()

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
      recover this~_doc_string_action(s) end)

  fun tag _doc_string_action(
    s: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let s' =
      try
        _Build.value_with[ast.Literal](b, s, r)?
      else
        return _Build.bind_error(d, r, c, b, "DocString/LiteralString")
      end

    let value = ast.NodeWith[ast.DocString](
      _Build.info(d, r), c, ast.DocString(s'))
    (value, b)
