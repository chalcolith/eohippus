use ast = "../ast"

class OperatorBuilder
  let _token: TokenBuilder
  let _keyword: KeywordBuilder

  var _prefix_op: (NamedRule | None) = None
  var _binary_op: (NamedRule | None) = None
  var _postfix_op: (NamedRule | None) = None

  new create(token: TokenBuilder, keyword: KeywordBuilder) =>
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
              kwd_return
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
      let binary_op' =
        recover val
          NamedRule("Operator_Binary", None) // TODO
        end
      _binary_op = binary_op'
      binary_op'
    end
