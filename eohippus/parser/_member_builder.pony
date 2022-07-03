use ast = "../ast"
use ".."

class _MemberBuilder
  let _trivia: _TriviaBuilder
  let _literal: _LiteralBuilder

  var _docstring: (NamedRule | None) = None

  new create(trivia: _TriviaBuilder, literal: _LiteralBuilder) =>
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
      let trivia = _trivia.trivia()
      let post_trivia = _trivia.post_trivia()
      let literal_string = _literal.string()

      let t1 = Variable
      let s = Variable
      let t2 = Variable
      let docstring' =
        recover val
          NamedRule("DocString",
            Conj([
              Bind(t1, trivia)
              Bind(s, literal_string)
              Bind(t2, post_trivia)
            ]),
            this~_docstring_action(t1, s, t2))
        end
      _docstring = docstring'
      docstring'
    end

  fun tag _docstring_action(t1: Variable, s: Variable, t2: Variable,
    r: Success, c: ast.NodeSeq[ast.Node], b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let t1': ast.Trivia =
      try
        b(t1)?._2(0)? as ast.Trivia
      else
        return (ast.ErrorSection(_Build.info(r), c,
          ErrorMsg.internal_ast_node_not_bound("Docstring/Trivia")),
            b)
      end

    let s': ast.LiteralString =
      try
        b(s)?._2(0)? as ast.LiteralString
      else
        return (ast.ErrorSection(_Build.info(r), c,
          ErrorMsg.internal_ast_node_not_bound("Docstring/LiteralString")),
              b)
      end

    let t2': ast.Trivia =
      try
        b(t2)?._2(0)? as ast.Trivia
      else
        return (ast.ErrorSection(_Build.info(r), c,
          ErrorMsg.internal_ast_node_not_bound("Docstring/PostTrivia")), b)
      end

    (ast.Docstring(_Build.info(r), c, t1', t2', s'), b)
