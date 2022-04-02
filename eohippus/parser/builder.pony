use ast = "../ast"

class Builder
  let _context: Context
  let _token: _TokenBuilder
  let _trivia: _TriviaBuilder
  let _literal: _LiteralBuilder
  let _expression: _ExpressionBuilder
  let _src_file: _SrcFileBuilder

  new create(context: Context) =>
    _context = context
    _token = _TokenBuilder(_context)
    _trivia = _TriviaBuilder(_context, _token)
    _literal = _LiteralBuilder(_context, _token)
    _expression = _ExpressionBuilder(_context)

    _src_file = _SrcFileBuilder(_trivia, _token, _literal, _expression)

  fun ref src_file(): NamedRule => _src_file.src_file()

  fun ref expression_identifier(): NamedRule => _expression.identifier()

  fun ref literal(): NamedRule => _literal.literal()
  fun ref literal_bool(): NamedRule => _literal.bool()
  fun ref literal_integer(): NamedRule => _literal.integer()
  fun ref literal_float(): NamedRule => _literal.float()
  fun ref literal_char(): NamedRule => _literal.char()
  fun ref literal_string(): NamedRule => _literal.string()

  fun ref trivia(): NamedRule => _trivia.trivia()
  fun ref comment(): NamedRule => _trivia.comment()
  fun ref ws(): NamedRule => _trivia.ws()
  fun ref eol(): NamedRule => _trivia.eol()
  fun ref eof(): NamedRule => _trivia.eof()
