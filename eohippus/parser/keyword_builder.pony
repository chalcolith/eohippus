use ast = "../ast"

class KeywordBuilder
  let _context: Context
  let _trivia: TriviaBuilder

  var _addressof: (NamedRule | None) = None
  var _as: (NamedRule | None) = None
  var _break: (NamedRule | None) = None
  var _compile_error: (NamedRule | None) = None
  var _compile_intrinsic: (NamedRule | None) = None
  var _continue: (NamedRule | None) = None
  var _digestof: (NamedRule | None) = None
  var _error: (NamedRule | None) = None
  var _if: (NamedRule | None) = None
  var _loc: (NamedRule | None) = None
  var _not: (NamedRule | None) = None
  var _primitive: (NamedRule | None) = None
  var _return: (NamedRule | None) = None
  var _this: (NamedRule | None) = None
  var _use: (NamedRule | None) = None

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

  fun ref kwd_return(): NamedRule =>
    _kwd_rule({() => _return}, {ref (r) => _return = r},
      "Keyword_Return", ast.Keywords.kwd_return())

  fun ref kwd_as(): NamedRule =>
    _kwd_rule({() => _as}, {ref (r) => _as = r},
      "Keyword_As", ast.Keywords.kwd_as())

  fun ref kwd_break(): NamedRule =>
    _kwd_rule({() => _break}, {ref (r) => _break = r},
      "Keyword_Break", ast.Keywords.kwd_break())

  fun ref kwd_continue(): NamedRule =>
    _kwd_rule({() => _continue}, {ref (r) => _continue = r},
      "Keyword_Continue", ast.Keywords.kwd_continue())

  fun ref kwd_error(): NamedRule =>
    _kwd_rule({() => _error}, {ref (r) => _error = r },
      "Keyword_Error", ast.Keywords.kwd_error())

  fun ref kwd_compile_intrinsic(): NamedRule =>
    _kwd_rule({() => _compile_intrinsic}, {ref (r) => _compile_intrinsic = r},
      "Keyword_CompileIntrinsic", ast.Keywords.kwd_compile_intrinsic())

  fun ref kwd_compile_error(): NamedRule =>
    _kwd_rule({() => _compile_error}, {ref (r) => _compile_error = r},
      "Keyword_CompileError", ast.Keywords.kwd_compile_error())
