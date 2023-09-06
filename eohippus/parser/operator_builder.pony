use ast = "../ast"

class OperatorBuilder
  let _trivia: TriviaBuilder
  let _token: TokenBuilder
  let _keyword: KeywordBuilder

  var _prefix_op: (NamedRule | None) = None
  var _binary_op: (NamedRule | None) = None
  var _postfix_op: (NamedRule | None) = None

  new create(
    trivia: TriviaBuilder,
    token: TokenBuilder,
    keyword: KeywordBuilder)
  =>
    _trivia = trivia
    _token = token
    _keyword = keyword

  fun ref prefix_op(): NamedRule =>
    match _prefix_op
    | let r: NamedRule => r
    else
      let kwd_return = _keyword(ast.Keywords.kwd_return())
      let kwd_not = _keyword(ast.Keywords.kwd_not())
      let kwd_addressof = _keyword(ast.Keywords.kwd_addressof())
      let kwd_digestof = _keyword(ast.Keywords.kwd_digestof())
      let minus = _token(ast.Tokens.minus())
      let minus_tilde = _token(ast.Tokens.minus_tilde())

      let prefix_op' =
        recover val
          NamedRule("Operator_Prefix",
            Disj([
              kwd_not
              kwd_addressof
              kwd_digestof
              minus
              minus_tilde
            ]))
        end
      _prefix_op = prefix_op'
      prefix_op'
    end

  fun ref postfix_op(): NamedRule =>
    match _postfix_op
    | let r: NamedRule => r
    else
      let dot = _token(ast.Tokens.dot())
      let tilde = _token(ast.Tokens.tilde())
      let chain = _token(ast.Tokens.chain())

      let postfix_op' =
        recover val
          NamedRule("Operator_Postfix",
            Disj([
              chain
              tilde
              dot
            ]))
        end

      _postfix_op = postfix_op'
      postfix_op'
    end

  fun ref binary_op(): NamedRule =>
    match _binary_op
    | let r: NamedRule => r
    else
      let trivia = _trivia.trivia()

      // we do this with literals because we don't need to be memoizing
      // all these failures everywhere
      // longer ones need to go first because PEG
      let binary_op' =
        recover val
          NamedRule("Operator_Binary",
            _Build.with_post[ast.Trivia](
              recover val
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
                    Literal(ast.Tokens.greater())
                  ])
              end,
              trivia,
              {(r,c,b,p) =>
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
                    _Build.info(r), c, ast.Keyword(str)
                    where post_trivia' = p)
                  (value, b)
                else
                  let value = ast.NodeWith[ast.Token](
                    _Build.info(r), c, ast.Token(str)
                    where post_trivia' = p)
                  (value, b)
                end
              }))
        end
      _binary_op = binary_op'
      binary_op'
    end
