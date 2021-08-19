use "kiuatan"
use "../ast"

class ParserBuilder[CH: ((U8 | U16) & UnsignedInteger[CH])]
  let _context: ParserContext[CH]
  let _trivia: _Trivia[CH]
  let _literal: _Literal[CH]

  var _literal_bool: (NamedRule[CH, ParserData[CH], AstNode[CH]] | None) = None

  new create(context: ParserContext[CH]) =>
    _context = context
    _trivia = _Trivia[CH](_context)
    _literal = _Literal[CH](_context)

  fun ref literal_bool(): NamedRule[CH, ParserData[CH], AstNode[CH]] =>
    _literal.bool()

  fun ref ws(): NamedRule[CH, ParserData[CH], AstNode[CH]] => _trivia.ws()
  fun ref eol(): NamedRule[CH, ParserData[CH], AstNode[CH]] => _trivia.eol()
  fun ref eof(): NamedRule[CH, ParserData[CH], AstNode[CH]] => _trivia.eof()
