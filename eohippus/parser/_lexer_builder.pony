use ast = "../ast"
use ".."

class _LexerBuilder
  let _context: Context

  var _double_quote: (NamedRule | None) = None
  var _triple_double_quote: (NamedRule | None) = None

  new create(context: Context) =>
    _context = context

  fun ref double_quote(): NamedRule =>
    match _double_quote
    | let r: NamedRule => r
    else
      recover val
        NamedRule("Glyph_Double_Quote",
          Single("\"",
            {(r, _, b) => (ast.GlyphDoubleQuote(_Build.info(r)), b)}))
      end
    end

  fun ref triple_double_quote(): NamedRule =>
    match _triple_double_quote
    | let r: NamedRule => r
    else
      recover val
        NamedRule("Glyph_Triple_Double_Quote",
          Literal("\"\"\"",
            {(r, _, b) => (ast.GlyphTripleDoubleQuote(_Build.info(r)), b)}))
      end
    end
