use ast = "../ast"

class Builder
  let _context: Context
  let _trivia: _Trivia
  let _glyph: _Glyph
  let _literal: _Literal

  var _literal_bool: (NamedRule | None) = None

  new create(context: Context) =>
    _context = context
    _trivia = _Trivia(_context)
    _glyph = _Glyph(_context)
    _literal = _Literal(_context, _glyph)

  fun ref literal_bool(): NamedRule => _literal.bool()
  fun ref literal_integer(): NamedRule => _literal.integer()
  fun ref literal_float(): NamedRule => _literal.float()
  fun ref literal_char(): NamedRule => _literal.char()
  fun ref literal_string(): NamedRule => _literal.string()

  fun ref comment(): NamedRule => _trivia.comment()
  fun ref ws(): NamedRule => _trivia.ws()
  fun ref eol(): NamedRule => _trivia.eol()
  fun ref eof(): NamedRule => _trivia.eof()
