use ast = "../ast"

class Builder
  let _context: Context

  let token: TokenBuilder
  let trivia: TriviaBuilder
  let literal: LiteralBuilder
  let expression: ExpressionBuilder
  let member: MemberBuilder
  let typedef: TypedefBuilder
  let src_file: SrcFileBuilder

  new create(context: Context) =>
    _context = context

    token = TokenBuilder(_context)
    trivia = TriviaBuilder(_context, token)
    literal = LiteralBuilder(_context, token)
    expression = ExpressionBuilder(_context, trivia)
    member = MemberBuilder(trivia, literal)
    typedef = TypedefBuilder(trivia, token, expression, member)
    src_file = SrcFileBuilder(trivia, token, literal, expression, member,
      typedef)
