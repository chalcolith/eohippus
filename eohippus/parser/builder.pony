"""
Implements a [Kiuatan](/kiuatan/kiuatan--index/) PEG packrat grammar for the Pony language.

The grammar is built using the [Builder](/eohippus/eohippus-parser-Builder/) object.
"""

use ast = "../ast"

class Builder
  """
    Builds a [Kiuatan](/kiuatan/kiuatan--index/) grammar for the Pony language.
  """

  let _context: Context

  let trivia: TriviaBuilder
  let token: TokenBuilder
  let keyword: KeywordBuilder
  let operator: OperatorBuilder
  let literal: LiteralBuilder
  let type_type: TypeBuilder
  let expression: ExpressionBuilder
  let typedef: TypedefBuilder
  let src_file: SrcFileBuilder

  new create(context: Context) =>
    _context = context

    trivia = TriviaBuilder(_context)
    token = TokenBuilder(_context, trivia)
    keyword = KeywordBuilder(_context, trivia)
    operator = OperatorBuilder(trivia, token, keyword)
    literal = LiteralBuilder(_context, trivia, token, keyword)
    type_type = TypeBuilder(_context, token, keyword)
    let method_params = NamedRule("method parameters")
    let typedef_members = NamedRule("type definition members")
    expression = ExpressionBuilder(
      _context,
      trivia,
      token,
      keyword,
      operator,
      literal,
      type_type,
      method_params,
      typedef_members)
    typedef = TypedefBuilder(
      trivia,
      token,
      keyword,
      literal,
      type_type,
      expression,
      method_params,
      typedef_members)
    src_file = SrcFileBuilder(
      trivia, token, keyword, literal, type_type, expression, typedef)
