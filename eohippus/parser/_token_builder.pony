use ast = "../ast"
use ".."

class _TokenBuilder
  let _context: Context

  var _double_quote: (NamedRule | None) = None
  var _triple_double_quote: (NamedRule | None) = None
  var _semicolon: (NamedRule | None) = None

  new create(context: Context) =>
    _context = context

  fun ref double_quote(): NamedRule =>
    match _double_quote
    | let r: NamedRule => r
    else
      let double_quote' =
        recover val
          NamedRule("Token_Double_Quote",
            Single("\"",
              {(r, _, b) => (ast.Token(_Build.info(r), ast.TokenDoubleQuote), b)}))
        end
      _double_quote = double_quote'
      double_quote'
    end

  fun ref triple_double_quote(): NamedRule =>
    match _triple_double_quote
    | let r: NamedRule => r
    else
      let triple_double_quote' =
        recover val
          NamedRule("Token_Triple_Double_Quote",
            Literal("\"\"\"",
              {(r, _, b) =>
                (ast.Token(_Build.info(r), ast.TokenTripleDoubleQuote), b)
              }))
        end
      _triple_double_quote = triple_double_quote'
      triple_double_quote'
    end

  fun ref semicolon(): NamedRule =>
    match _semicolon
    | let r: NamedRule => r
    else
      let semicolon' =
        recover val
          NamedRule("Token_Semicolon",
            Literal(";",
              {(r, _, b) =>
                (ast.Token(_Build.info(r), ast.TokenSemicolon), b)
              }))
        end
      _semicolon = semicolon'
      semicolon'
    end
