use "collections"

use ast = "../ast"

class TriviaBuilder
  let _context: Context

  let trivia: NamedRule = NamedRule("trivia")
  let comment: NamedRule = NamedRule("a comment")
  let comment_line: NamedRule = NamedRule("a line comment")
  let comment_nested: NamedRule = NamedRule("a nested comment")
  let ws: NamedRule = NamedRule("whitespace")
  let eol: NamedRule = NamedRule("a line end")
  let dol: NamedRule = NamedRule("a double end of line")
  let eof: NamedRule = NamedRule("end of file")

  new create(context: Context) =>
    _context = context
    _build_trivia()
    _build_comment()
    _build_comment_line()
    _build_comment_nested()
    _build_ws()
    _build_eol()
    _build_dol()
    _build_eof()

  fun ref _build_trivia() =>
    trivia.set_body(Plus(Disj([ comment; ws; eol ])))

  fun ref _build_comment() =>
    comment.set_body(Disj([ comment_line; comment_nested ]))

  fun ref _build_comment_line() =>
    // '//' (!EOL .)* EOL
    comment_line.set_body(
      Conj(
        [ Literal("//")
          Star(Conj([ Neg(eol); Single() ]))
          Look(Disj([ eol; eof ])) ]),
      {(d, r, c, b) =>
        let value = ast.NodeWith[ast.Trivia](
          _Build.info(d, r), c, ast.Trivia(ast.LineCommentTrivia))
        (value, b) })

  fun ref _build_comment_nested() =>
    // '/*' (!'*/' .)* '*/'
    comment_nested.set_body(
      Conj(
        [ Literal("/*")
          Star(Conj([ Neg(Literal("*/")); Single() ]))
          Literal("*/") ]),
      {(d, r, c, b) =>
        let value = ast.NodeWith[ast.Trivia](
          _Build.info(d, r), c, ast.Trivia(ast.NestedCommentTrivia))
        (value, b) })

  fun ref _build_ws() =>
    ws.set_body(
      Plus(Single(" \t")),
      {(d, r, c, b) =>
        let value = ast.NodeWith[ast.Trivia](
          _Build.info(d, r), c, ast.Trivia(ast.WhiteSpaceTrivia))
        (value, b) })

  fun ref _build_eol() =>
    eol.set_body(
      Disj(
        [ Literal("\r\n")
          Literal("\n")
          Literal("\r") ]),
        {(d, r, c, b) =>
          let value = ast.NodeWith[ast.Trivia](
            _Build.info(d, r), c, ast.Trivia(ast.EndOfLineTrivia))
          (value, b) })

  fun ref _build_dol() =>
    dol.set_body(Star(Conj([ eol; Ques(ws) ]), 2))

  fun ref _build_eof() =>
    eof.set_body(
      Neg(Single),
      {(d, r, c, b) =>
        let value = ast.NodeWith[ast.Trivia](
          _Build.info(d, r), c, ast.Trivia(ast.EndOfFileTrivia))
        (value, b) })
