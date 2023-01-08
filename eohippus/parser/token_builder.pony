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

  new create(context: Context, trivia: TriviaBuilder) =>
    _context = context
    _trivia = trivia

    _tokens = Map[String, NamedRule]

    let t = _trivia.trivia()
    _add_rule("Token_Double_Quote", ast.Tokens.double_quote(), t, _tokens)
    _add_rule("Token_Triple_Double_Quote", ast.Tokens.triple_double_quote(),
      t, _tokens)
    _add_rule("Token_Semicolon", ast.Tokens.semicolon(), t, _tokens)
    _add_rule("Token_Equals", ast.Tokens.equals(), t, _tokens)
    _add_rule("Token_Backslash", ast.Tokens.backslash(), t, _tokens)
    _add_rule("Token_Comma", ast.Tokens.comma(), t, _tokens)
    _add_rule("Token_Minus", ast.Tokens.minus(), t, _tokens)
    _add_rule("Token_MinusTilde", ast.Tokens.minus_tilde(), t, _tokens)
    _add_rule("Token_Dot", ast.Tokens.dot(), t, _tokens)
    _add_rule("Token_Tilde", ast.Tokens.tilde(), t, _tokens)
    _add_rule("Token_Chain", ast.Tokens.chain(), t, _tokens)
    _add_rule("Token_Subtype", ast.Tokens.subtype(), t, _tokens)

  fun tag _add_rule(
    name: String,
    str: String,
    t: NamedRule,
    m: Map[String, NamedRule])
  =>
    let rule =
      recover val
        NamedRule(name,
          _Build.with_post[ast.Trivia](
            recover Literal(str) end, t,
            {(r, _, b, p) => (ast.Token(_Build.info(r), p), b) }
          ))
      end
    m.insert(str, rule)

  fun apply(str: String): NamedRule =>
    try
      _tokens(str)?
    else
      recover val
        NamedRule("ERROR " + StringUtil.escape(str),
          Error("Invalid token '" + StringUtil.escape(str) + "'"))
      end
    end
