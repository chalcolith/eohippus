use ast = "../ast"

class Builder
  let _context: Context

  let token: TokenBuilder
  let keyword: KeywordBuilder
  let trivia: TriviaBuilder
  let literal: LiteralBuilder
  let expression: ExpressionBuilder
  let member: MemberBuilder
  let typedef: TypedefBuilder
  let src_file: SrcFileBuilder

  new create(context: Context) =>
    _context = context

    token = TokenBuilder(_context)
    keyword = KeywordBuilder(_context)
    trivia = TriviaBuilder(_context, token)
    literal = LiteralBuilder(_context, token)
    expression = ExpressionBuilder(_context, trivia, token, keyword)
    member = MemberBuilder(trivia, literal)
    typedef = TypedefBuilder(trivia, token, keyword, expression, member)
    src_file = SrcFileBuilder(trivia, token, keyword, literal, expression,
      member, typedef)
