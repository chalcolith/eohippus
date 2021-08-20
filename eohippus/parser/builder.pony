use ast = "../ast"

class Builder
  let _context: Context
  let _trivia: _Trivia
  let _literal: _Literal

  var _literal_bool: (NamedRule | None) = None

  new create(context: Context) =>
    _context = context
    _trivia = _Trivia(_context)
    _literal = _Literal(_context)

  fun ref literal_bool(): NamedRule => _literal.bool()

  fun ref comment(): NamedRule => _trivia.comment()
  fun ref ws(): NamedRule => _trivia.ws()
  fun ref eol(): NamedRule => _trivia.eol()
  fun ref eof(): NamedRule => _trivia.eof()

primitive _Build
  fun info(success: Success): ast.SrcInfo =>
    ast.SrcInfo(success.data.locator(), success.start, success.next)
