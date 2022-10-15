use ast = "../ast"

class KeywordBuilder
  let _context: Context
  let _trivia: TriviaBuilder

  var _use: (NamedRule | None) = None
  var _if: (NamedRule | None) = None
  var _not: (NamedRule | None) = None
  var _primitive: (NamedRule | None) = None
  var _loc: (NamedRule | None) = None
  var _this: (NamedRule | None) = None
  var _addressof: (NamedRule | None) = None
  var _digestof: (NamedRule | None) = None

  new create(context: Context, trivia: TriviaBuilder) =>
    _context = context
    _trivia = trivia

  fun ref _kwd_rule(get: {(): (NamedRule | None)}, set: {ref (NamedRule)},
    name: String, str: String): NamedRule
  =>
    match get()
    | let r: NamedRule => r
    else
      let trivia = _trivia.trivia()
      let rule =
        recover val
          let post = Variable

          NamedRule(name,
            _Build.with_post[ast.Trivia](
              recover
                Conj([
                  Literal(str)
                  Neg(Single(_Letters.with_underscore()))
                ])
              end,
              trivia,
              {(r, _, b, p) => (ast.Keyword(_Build.info(r), p, str), b)}
            ))
        end
      set(rule)
      rule
    end

  fun ref kwd_use(): NamedRule =>
    _kwd_rule({() => _use}, {ref (r) => _use = r}, "Keyword_Use",
      ast.Keywords.kwd_use())

  fun ref kwd_if(): NamedRule =>
    _kwd_rule({() => _if}, {ref (r) => _if = r}, "Keyword_If",
      ast.Keywords.kwd_if())

  fun ref kwd_not(): NamedRule =>
    _kwd_rule({() => _not}, {ref (r) => _not = r}, "Keyword_Not",
      ast.Keywords.kwd_not())

  fun ref kwd_primitive(): NamedRule =>
    _kwd_rule({() => _primitive}, {ref (r) => _primitive = r},
      "Keyword_Primitive", ast.Keywords.kwd_primitive())

  fun ref kwd_loc(): NamedRule =>
    _kwd_rule({() => _loc}, {ref (r) => _loc = r}, "Keyword_Loc",
      ast.Keywords.kwd_loc())

  fun ref kwd_this(): NamedRule =>
    _kwd_rule({() => _this}, {ref (r) => _this = r}, "Keyword_This",
      ast.Keywords.kwd_this())

  fun ref kwd_addressof(): NamedRule =>
    _kwd_rule({() => _addressof}, {ref (r) => _addressof = r},
      "Keyword_Addressof", ast.Keywords.kwd_addressof())

  fun ref kwd_digestof(): NamedRule =>
    _kwd_rule({() => _digestof}, {ref (r) => _digestof = r},
    "Keyword_Digestof", ast.Keywords.kwd_digestof())
