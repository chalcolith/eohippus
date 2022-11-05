use ast = "../ast"

class Builder
  let _context: Context

  let trivia: TriviaBuilder
  let token: TokenBuilder
  let keyword: KeywordBuilder
  let operator: OperatorBuilder
  let literal: LiteralBuilder
  let type_builder: TypeBuilder
  let expression: ExpressionBuilder
  let member: MemberBuilder
  let typedef: TypedefBuilder
  let src_file: SrcFileBuilder

  new create(context: Context) =>
    _context = context

    trivia = TriviaBuilder(_context)
    token = TokenBuilder(_context, trivia)
    keyword = KeywordBuilder(_context, trivia)
    operator = OperatorBuilder(token, keyword)
    literal = LiteralBuilder(_context, trivia, token, keyword)
    type_builder = TypeBuilder(_context)
    expression = ExpressionBuilder(_context, trivia, token, keyword,
      operator, literal, type_builder)
    member = MemberBuilder(trivia, literal)
    typedef = TypedefBuilder(trivia, token, keyword, expression, member)
    src_file = SrcFileBuilder(trivia, token, keyword, literal, expression,
      member, typedef)
