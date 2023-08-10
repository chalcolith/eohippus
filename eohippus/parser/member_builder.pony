use ast = "../ast"
use ".."

class MemberBuilder
  let _trivia: TriviaBuilder
  let _literal: LiteralBuilder

  var _doc_string: (NamedRule | None) = None

  new create(trivia: TriviaBuilder, literal: LiteralBuilder) =>
    _trivia = trivia
    _literal = literal

  fun ref error_section(
    allowed: ReadSeq[NamedRule] val,
    message: String)
    : RuleNode
  =>
    let trivia = _trivia.trivia()
    let dol = _trivia.dol()
    let eof = _trivia.eof()

    recover val
      NamedRule("Error_Section",
        Conj(
          [
            Neg(Disj([Disj(allowed); eof]))
            Plus(Conj([Neg(Disj([dol; eof])); Single()]))
            Look(Disj([dol; trivia; eof]))
          ],
          {(r, c, b) =>
            let value = ast.NodeWith[ast.ErrorSection](
              _Build.info(r), c, ast.ErrorSection(message))
            (value, b) }))
    end

  fun ref doc_string(): NamedRule =>
    match _doc_string
    | let r: NamedRule => r
    else
      let literal_string = _literal.string()

      let s = Variable("s")
      let doc_string' =
        recover val
          NamedRule("DocString",
            Conj(
              [ Bind(s, literal_string) ]),
            this~_doc_string_action(s))
        end
      _doc_string = doc_string'
      doc_string'
    end

  fun tag _doc_string_action(
    s: Variable,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let s': ast.NodeWith[ast.LiteralString] =
      try
        _Build.value(b, s)? as ast.NodeWith[ast.LiteralString]
      else
        return _Build.bind_error(r, c, b, "DocString/LiteralString")
      end

    let value = ast.NodeWith[ast.DocString](
      _Build.info(r), c, ast.DocString(s'))
    (value, b)
