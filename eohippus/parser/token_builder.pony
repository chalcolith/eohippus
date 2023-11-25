use "collections"

use ast = "../ast"
use ".."

primitive _Letters
  fun apply(): String =>
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

  fun with_underscore(): String =>
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"

primitive _Digits
  fun apply(): String =>
    "0123456789"

  fun with_underscore(): String =>
    "0123456789_"

primitive _Hex
  fun apply(): String =>
    "0123456789abcdefABCDEF"

  fun with_underscore(): String =>
    "0123456789abcdefABCDEF_"

primitive _Binary
  fun apply(): String =>
    "01"

  fun with_underscore(): String =>
    "01_"

class TokenBuilder
  let _context: Context
  let _trivia: TriviaBuilder

  let _tokens: Map[String, NamedRule]
  let identifier: NamedRule = NamedRule("an identifier")

  new create(context: Context, trivia: TriviaBuilder) =>
    _context = context
    _trivia = trivia
    _tokens = Map[String, NamedRule]
    _build_identifier()

    let t = _trivia.trivia
    _add_rule(ast.Tokens.amp(), t, _tokens)
    _add_rule(ast.Tokens.arrow(), t, _tokens)
    _add_rule(ast.Tokens.at(), t, _tokens)
    _add_rule(ast.Tokens.backslash(), t, _tokens)
    _add_rule(ast.Tokens.bang(), t, _tokens)
    _add_rule(ast.Tokens.bang_equal(), t, _tokens)
    _add_rule(ast.Tokens.bang_equal_tilde(), t, _tokens)
    _add_rule(ast.Tokens.bar(), t, _tokens)
    _add_rule(ast.Tokens.chain(), t, _tokens)
    _add_rule(ast.Tokens.close_curly(), t, _tokens)
    _add_rule(ast.Tokens.close_paren(), t, _tokens)
    _add_rule(ast.Tokens.close_square(), t, _tokens)
    _add_rule(ast.Tokens.colon(), t, _tokens)
    _add_rule(ast.Tokens.comma(), t, _tokens)
    _add_rule(ast.Tokens.decimal_point(), t, _tokens)
    _add_rule(ast.Tokens.dot(), t, _tokens)
    _add_rule(ast.Tokens.double_quote(), t, _tokens)
    _add_rule(ast.Tokens.equals(), t, _tokens)
    _add_rule(ast.Tokens.equal_arrow(), t, _tokens)
    _add_rule(ast.Tokens.equal_equal(), t, _tokens)
    _add_rule(ast.Tokens.equal_equal_tilde(), t, _tokens)
    _add_rule(ast.Tokens.greater(), t, _tokens)
    _add_rule(ast.Tokens.greater_equal(), t, _tokens)
    _add_rule(ast.Tokens.greater_equal_tilde(), t, _tokens)
    _add_rule(ast.Tokens.greater_tilde(), t, _tokens)
    _add_rule(ast.Tokens.hash(), t, _tokens)
    _add_rule(ast.Tokens.hat(), t, _tokens)
    _add_rule(ast.Tokens.less(), t, _tokens)
    _add_rule(ast.Tokens.less_equal(), t, _tokens)
    _add_rule(ast.Tokens.less_equal_tilde(), t, _tokens)
    _add_rule(ast.Tokens.less_tilde(), t, _tokens)
    _add_rule(ast.Tokens.minus(), t, _tokens)
    _add_rule(ast.Tokens.minus_tilde(), t, _tokens)
    _add_rule(ast.Tokens.open_curly(), t, _tokens)
    _add_rule(ast.Tokens.open_paren(), t, _tokens)
    _add_rule(ast.Tokens.open_square(), t, _tokens)
    _add_rule(ast.Tokens.percent(), t, _tokens)
    _add_rule(ast.Tokens.percent_percent(), t, _tokens)
    _add_rule(ast.Tokens.percent_percent_tilde(), t, _tokens)
    _add_rule(ast.Tokens.percent_tilde(), t, _tokens)
    _add_rule(ast.Tokens.plus(), t, _tokens)
    _add_rule(ast.Tokens.plus_tilde(), t, _tokens)
    _add_rule(ast.Tokens.ques(), t, _tokens)
    _add_rule(ast.Tokens.semicolon(), t, _tokens)
    _add_rule(ast.Tokens.shift_left(), t, _tokens)
    _add_rule(ast.Tokens.shift_left_tilde(), t, _tokens)
    _add_rule(ast.Tokens.shift_right(), t, _tokens)
    _add_rule(ast.Tokens.shift_right_tilde(), t, _tokens)
    _add_rule(ast.Tokens.single_quote(), t, _tokens)
    _add_rule(ast.Tokens.slash(), t, _tokens)
    _add_rule(ast.Tokens.slash_tilde(), t, _tokens)
    _add_rule(ast.Tokens.star(), t, _tokens)
    _add_rule(ast.Tokens.star_tilde(), t, _tokens)
    _add_rule(ast.Tokens.subtype(), t, _tokens)
    _add_rule(ast.Tokens.tilde(), t, _tokens)
    _add_rule(ast.Tokens.triple_double_quote(), t, _tokens)
    _add_rule(ast.Tokens.underscore(), t, _tokens)

  fun tag _add_rule(
    str: String,
    trivia: NamedRule,
    m: Map[String, NamedRule])
  =>
    let rule =
      NamedRule(
        "a '" + StringUtil.escape(str) + "' token",
        _Build.with_post[ast.Trivia](
          Literal(str),
          trivia,
          {(d, r, c, b, p) =>
            let next =
              try
                p(0)?.src_info().start
              else
                r.next
              end
            let string =
              recover val
                String .> concat(r.start.values(next))
              end
            let value = ast.NodeWith[ast.Token](
              _Build.info(d, r), c, ast.Token(string)
              where post_trivia' = p)
            (value, b) })
        where memoize_failures' = false)
    m.insert(str, rule)

  fun apply(str: String): NamedRule box =>
    try
      _tokens(str)?
    else
      let msg = recover val "INVALID TOKEN '" + StringUtil.escape(str) + "'" end
      NamedRule(msg, Error(msg))
    end

  fun ref _build_identifier() =>
    let id_chars: String = _Letters.with_underscore() + _Digits() + "'"
    identifier.set_body(
      _Build.with_post[ast.Trivia](
        Disj(
          [ Conj(
              [ Single(ast.Tokens.underscore())
                Star(Single(id_chars)) ])
            Conj(
              [ Single(_Letters())
                Star(Single(id_chars)) ]) ]),
        _trivia.trivia,
        {(d, r, c, b, p) =>
          let next =
            try
              p(0)?.src_info().start
            else
              r.next
            end
          let string =
            recover val
              String .> concat(r.start.values(next))
            end
          let value = ast.NodeWith[ast.Identifier](
            _Build.info(d, r), c, ast.Identifier(string)
            where post_trivia' = p)
          (value, b) }))
