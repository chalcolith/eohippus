use ast = "../ast"

class OperatorBuilder
  let _trivia: TriviaBuilder
  let _token: TokenBuilder
  let _keyword: KeywordBuilder

  let prefix_op: NamedRule = NamedRule("a prefix operator")
  let binary_op: NamedRule = NamedRule("a binary operator")
  let postfix_op: NamedRule = NamedRule("a postfix operator")

  new create(
    trivia: TriviaBuilder,
    token: TokenBuilder,
    keyword: KeywordBuilder)
  =>
    _trivia = trivia
    _token = token
    _keyword = keyword

    _build_prefix_op()
    _build_postfix_op()
    _build_binary_op()

  fun ref _build_prefix_op() =>
    prefix_op.set_body(
      Disj(
        [ _keyword(ast.Keywords.kwd_not())
          _keyword(ast.Keywords.kwd_addressof())
          _keyword(ast.Keywords.kwd_digestof())
          _token(ast.Tokens.minus_tilde())
          _token(ast.Tokens.minus()) ]))

  fun ref _build_postfix_op() =>
    postfix_op.set_body(
      Disj(
        [ _token(ast.Tokens.chain())
          _token(ast.Tokens.tilde())
          _token(ast.Tokens.dot()) ]))

  fun ref _build_binary_op() =>
    binary_op.set_body(
      _Build.with_post[ast.Trivia](
        Disj(
          [ Literal(ast.Keywords.kwd_and())
            Literal(ast.Keywords.kwd_or())
            Literal(ast.Keywords.kwd_xor())

            Literal(ast.Tokens.plus_tilde())
            Literal(ast.Tokens.minus_tilde())
            Literal(ast.Tokens.star_tilde())
            Literal(ast.Tokens.slash_tilde())
            Literal(ast.Tokens.percent_percent_tilde())
            Literal(ast.Tokens.percent_tilde())
            Literal(ast.Tokens.plus())
            Literal(ast.Tokens.minus())
            Literal(ast.Tokens.star())
            Literal(ast.Tokens.slash())
            Literal(ast.Tokens.percent_percent())
            Literal(ast.Tokens.percent())

            Literal(ast.Tokens.shift_left_tilde())
            Literal(ast.Tokens.shift_right_tilde())
            Literal(ast.Tokens.shift_left())
            Literal(ast.Tokens.shift_right())

            Literal(ast.Tokens.equal_equal_tilde())
            Literal(ast.Tokens.bang_equal_tilde())
            Literal(ast.Tokens.less_equal_tilde())
            Literal(ast.Tokens.less_tilde())
            Literal(ast.Tokens.greater_equal_tilde())
            Literal(ast.Tokens.greater_tilde())
            Literal(ast.Tokens.equal_equal())
            Literal(ast.Tokens.bang_equal())
            Literal(ast.Tokens.less_equal())
            Literal(ast.Tokens.less())
            Literal(ast.Tokens.greater_equal())
            Literal(ast.Tokens.greater()) ]
          ),
        _trivia.trivia,
        {(d, r, c, b, p) =>
          let kwd_and = ast.Keywords.kwd_and()
          let kwd_or = ast.Keywords.kwd_or()
          let kwd_xor = ast.Keywords.kwd_xor()

          let next =
            try
              p(0)?.src_info().start
            else
              r.next
            end

          let str = recover val String .> concat(r.start.values(next)) end

          if (str == kwd_and) or (str == kwd_or) or (str == kwd_xor) then
            let value = ast.NodeWith[ast.Keyword](
              _Build.info(d, r), c, ast.Keyword(str)
              where post_trivia' = p)
            (value, b)
          else
            let value = ast.NodeWith[ast.Token](
              _Build.info(d, r), c, ast.Token(str)
              where post_trivia' = p)
            (value, b)
          end
        }
      ))
