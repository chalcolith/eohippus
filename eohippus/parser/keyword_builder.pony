use ast = "../ast"

class KeywordBuilder
  let _context: Context

  var _use: (NamedRule | None) = None
  var _if: (NamedRule | None) = None
  var _not: (NamedRule | None) = None
  var _primitive: (NamedRule | None) = None
  var _loc: (NamedRule | None) = None
  var _this: (NamedRule | None) = None

  new create(context: Context) =>
    _context = context

  fun ref _kwd_rule(get: {(): (NamedRule | None)}, set: {ref (NamedRule)},
    name: String, str: String): NamedRule
  =>
    match get()
    | let r: NamedRule => r
    else
      let rule =
        recover val
          NamedRule(name,
            Conj([
              Literal(str, {(r, _, b) => (ast.Keyword(_Build.info(r)), b)})
              Neg(Single(_Letters.with_underscore()))
            ]))
        end
      set(rule)
      rule
    end

  fun ref kwd_use(): NamedRule =>
    _kwd_rule({() => _use}, {ref (r) => _use = r}, "Token_Use",
      ast.Keywords.kwd_use())

  fun ref kwd_if(): NamedRule =>
    _kwd_rule({() => _if}, {ref (r) => _if = r}, "Token_If",
      ast.Keywords.kwd_if())

  fun ref kwd_not(): NamedRule =>
    _kwd_rule({() => _not}, {ref (r) => _not = r}, "Token_Not",
      ast.Keywords.kwd_not())

  fun ref kwd_primitive(): NamedRule =>
    _kwd_rule({() => _primitive}, {ref (r) => _primitive = r},
      "Token_Primitive", ast.Keywords.kwd_primitive())

  fun ref kwd_loc(): NamedRule =>
    _kwd_rule({() => _loc}, {ref (r) => _loc = r}, "Token_Loc",
      ast.Keywords.kwd_loc())

  fun ref kwd_this(): NamedRule =>
    _kwd_rule({() => _this}, {ref (r) => _this = r}, "Token_This",
      ast.Keywords.kwd_this())
