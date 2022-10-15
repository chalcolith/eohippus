use ast = "../ast"
use ".."

class MemberBuilder
  let _trivia: TriviaBuilder
  let _literal: LiteralBuilder

  var _docstring: (NamedRule | None) = None

  new create(trivia: TriviaBuilder, literal: LiteralBuilder) =>
    _trivia = trivia
    _literal = literal

  fun ref errsec(allowed: ReadSeq[NamedRule] val, message: String): RuleNode =>
    let trivia = _trivia.trivia()
    let dol = _trivia.dol()
    let eof = _trivia.eof()

    recover val
      NamedRule("Error_Section",
        Conj(
          [
            Neg(Disj([Disj(allowed); eof]))
            Star(Conj([Neg(Disj([dol; eof])); Single()]), 1)
            Look(Disj([dol; trivia; eof]))
          ],
          {(r, c, b) =>
            (ast.ErrorSection(_Build.info(r), c, message), b)
          }
        ))
    end

  fun ref docstring(): NamedRule =>
    match _docstring
    | let r: NamedRule => r
    else
      let literal_string = _literal.string()

      let s = Variable
      let docstring' =
        recover val
          NamedRule("DocString",
            Conj([
              Bind(s, literal_string)
            ]),
            this~_docstring_action(s))
        end
      _docstring = docstring'
      docstring'
    end

  fun tag _docstring_action(s: Variable, r: Success, c: ast.NodeSeq[ast.Node],
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let s': ast.LiteralString =
      try
        _Build.value(b, s)? as ast.LiteralString
      else
        return _Build.bind_error(r, c, b, "Docstring/LiteralString")
      end
    (ast.Docstring(_Build.info(r), c, s'), b)
