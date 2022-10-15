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

  var _double_quote: (NamedRule | None) = None
  var _triple_double_quote: (NamedRule | None) = None
  var _semicolon: (NamedRule | None) = None
  var _equals: (NamedRule | None) = None
  var _backslash: (NamedRule | None) = None
  var _comma: (NamedRule | None) = None
  var _minus: (NamedRule | None) = None
  var _minus_tilde: (NamedRule | None) = None

  new create(context: Context, trivia: TriviaBuilder) =>
    _context = context
    _trivia = trivia

  fun ref _token_rule(get: {(): (NamedRule | None)}, set: {ref (NamedRule)},
    name: String, str: String) : NamedRule
  =>
    match get()
    | let r: NamedRule => r
    else
      let trivia = _trivia.trivia()

      let rule =
        recover val
          NamedRule(name,
            _Build.with_post[ast.Trivia](
              recover Literal(str) end,
              trivia,
              {(r, _, b, p) => (ast.Token(_Build.info(r), p), b)}
            ))
        end
      set(rule)
      rule
    end

  fun ref double_quote(): NamedRule =>
    _token_rule({() => _double_quote}, {ref (r) => _double_quote = r},
      "Token_Double_Quote", ast.Tokens.double_quote())

  fun ref triple_double_quote(): NamedRule =>
    _token_rule({() => _triple_double_quote},
      {ref (r) => _triple_double_quote = r},
      "Token_Triple_Double_Quote", ast.Tokens.triple_double_quote())

  fun ref semicolon(): NamedRule =>
    _token_rule({() => _semicolon}, {ref (r) => _semicolon = r},
      "Token_Semicolon", ast.Tokens.semicolon())

  fun ref equals(): NamedRule =>
    _token_rule({() => _equals}, {ref (r) => _equals = r}, "Token_Equals",
      ast.Tokens.equals())

  fun ref backslash(): NamedRule =>
    _token_rule({() => _backslash}, {ref (r) => _backslash = r},
      "Token_Backslash", ast.Tokens.backslash())

  fun ref comma(): NamedRule =>
    _token_rule({() => _comma}, {ref (r) => _comma = r}, "Token_Comma",
      ast.Tokens.comma())

  fun ref minus(): NamedRule =>
    _token_rule({() => _minus}, {ref (r) => _minus = r}, "Token_Minus",
      ast.Tokens.minus())

  fun ref minus_tilde(): NamedRule =>
    _token_rule({() => _minus_tilde}, {ref (r) => _minus_tilde = r},
    "Token_MinusTilde", ast.Tokens.minus_tilde())
