use ast = "../ast"
use ".."

class _TokenBuilder
  let _context: Context

  var _double_quote: (NamedRule | None) = None
  var _triple_double_quote: (NamedRule | None) = None
  var _semicolon: (NamedRule | None) = None
  var _equals: (NamedRule | None) = None

  var _use: (NamedRule | None) = None
  var _if: (NamedRule | None) = None
  var _not: (NamedRule | None) = None

  var _primitive: (NamedRule | None) = None

  new create(context: Context) =>
    _context = context

  fun ref _token_rule(get: {(): (NamedRule | None)}, set: {ref (NamedRule)},
    name: String, str: String) : NamedRule
  =>
    match get()
    | let r: NamedRule => r
    else
      let rule =
        recover val
          NamedRule(name,
            Literal(str, {(r, _, b) => (ast.Token(_Build.info(r), str), b)}))
        end
      set(rule)
      rule
    end

  fun ref glyph_double_quote(): NamedRule =>
    _token_rule({() => _double_quote}, {ref (r) => _double_quote = r},
      "Token_Double_Quote", "\"")

  fun ref glyph_triple_double_quote(): NamedRule =>
    _token_rule({() => _triple_double_quote},
      {ref (r) => _triple_double_quote = r},
      "Token_Triple_Double_Quote", "\"\"\"")

  fun ref glyph_semicolon(): NamedRule =>
    _token_rule({() => _semicolon}, {ref (r) => _semicolon = r},
      "Token_Semicolon", ";")

  fun ref glyph_equals(): NamedRule =>
    _token_rule({() => _equals}, {ref (r) => _equals = r}, "Token_Equals", "=")

  fun ref kwd_use(): NamedRule =>
    _token_rule({() => _use}, {ref (r) => _use = r}, "Token_Use", "use")

  fun ref kwd_if(): NamedRule =>
    _token_rule({() => _if}, {ref (r) => _if = r}, "Token_If", "if")

  fun ref kwd_not(): NamedRule =>
    _token_rule({() => _not}, {ref (r) => _not = r}, "Token_Not", "not")

  fun ref kwd_primitive(): NamedRule =>
    _token_rule({() => _primitive}, {ref (r) => _primitive = r},
      "Token_Primitive", "primitive")
