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
  var _identifier: (NamedRule | None) = None

  new create(context: Context, trivia: TriviaBuilder) =>
    _context = context
    _trivia = trivia

    _tokens = Map[String, NamedRule]

    let t = _trivia.trivia()
    _add_rule("Token_Amp", ast.Tokens.amp(), t, _tokens)
    _add_rule("Token_Arrow", ast.Tokens.arrow(), t, _tokens)
    _add_rule("Token_At", ast.Tokens.at(), t, _tokens)
    _add_rule("Token_Backslash", ast.Tokens.backslash(), t, _tokens)
    _add_rule("Token_Bang", ast.Tokens.bang(), t, _tokens)
    _add_rule("Token_Bar", ast.Tokens.bar(), t, _tokens)
    _add_rule("Token_Chain", ast.Tokens.chain(), t, _tokens)
    _add_rule("Token_Close_Curly", ast.Tokens.close_curly(), t, _tokens)
    _add_rule("Token_Close_Paren", ast.Tokens.close_paren(), t, _tokens)
    _add_rule("Token_Close_Square", ast.Tokens.close_square(), t, _tokens)
    _add_rule("Token_Colon", ast.Tokens.colon(), t, _tokens)
    _add_rule("Token_Comma", ast.Tokens.comma(), t, _tokens)
    _add_rule("Token_Decimal_Point", ast.Tokens.decimal_point(), t, _tokens)
    _add_rule("Token_Dot", ast.Tokens.dot(), t, _tokens)
    _add_rule("Token_Double_Quote", ast.Tokens.double_quote(), t, _tokens)
    _add_rule("Token_Equals", ast.Tokens.equals(), t, _tokens)
    _add_rule("Token_Hash", ast.Tokens.hash(), t, _tokens)
    _add_rule("Token_Hat", ast.Tokens.hat(), t, _tokens)
    _add_rule("Token_Minus", ast.Tokens.minus(), t, _tokens)
    _add_rule("Token_MinusTilde", ast.Tokens.minus_tilde(), t, _tokens)
    _add_rule("Token_Open_Curly", ast.Tokens.open_curly(), t, _tokens)
    _add_rule("Token_Open_Paren", ast.Tokens.open_paren(), t, _tokens)
    _add_rule("Token_Open_Square", ast.Tokens.open_square(), t, _tokens)
    _add_rule("Token_Ques", ast.Tokens.ques(), t, _tokens)
    _add_rule("Token_Semicolon", ast.Tokens.semicolon(), t, _tokens)
    _add_rule("Token_Single_Quote", ast.Tokens.single_quote(), t, _tokens)
    _add_rule("Token_Subtype", ast.Tokens.subtype(), t, _tokens)
    _add_rule("Token_Tilde", ast.Tokens.tilde(), t, _tokens)
    _add_rule("Token_Triple_Double_Quote", ast.Tokens.triple_double_quote(), t,
      _tokens)
    _add_rule("Token_Underscore", ast.Tokens.underscore(), t, _tokens)

  fun tag _add_rule(
    name: String,
    str: String,
    trivia: NamedRule,
    m: Map[String, NamedRule])
  =>
    let rule =
      recover val
        NamedRule(name,
          _Build.with_post[ast.Trivia](
            Literal(str),
            trivia,
            {(r, c, b, p) =>
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
                _Build.info(r), c, ast.Token(string)
                where post_trivia' = p)
              (value, b) }))
      end
    m.insert(str, rule)

  fun apply(str: String): NamedRule =>
    try
      _tokens(str)?
    else
      let msg = recover val "INVALID TOKEN '" + StringUtil.escape(str) + "'" end
      recover val
        NamedRule(msg, Error(msg))
      end
    end

  fun ref identifier(): NamedRule =>
    match _identifier
    | let r: NamedRule => r
    else
      let trivia = _trivia.trivia()
      let id_chars: String = _Letters.with_underscore() + _Digits() + "'"

      let identifier' =
        recover val
          NamedRule("Identifier",
            _Build.with_post[ast.Trivia](
              recover
                Disj(
                  [ Conj(
                      [ Single(ast.Tokens.underscore())
                        Star(Single(id_chars)) ])
                    Conj(
                      [ Single(_Letters())
                        Star(Single(id_chars)) ]) ])
              end,
              trivia,
              {(r, c, b, p) =>
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
                  _Build.info(r), c, ast.Identifier(string)
                  where post_trivia' = p)
                (value, b) }))
        end
      _identifier = identifier'
      identifier'
    end
