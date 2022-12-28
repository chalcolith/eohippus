use ast = "../ast"
use ".."

class LiteralBuilder
  let _context: Context
  let _trivia: TriviaBuilder
  let _token: TokenBuilder
  let _keyword: KeywordBuilder

  var _literal: (NamedRule | None) = None
  var _bool: (NamedRule | None) = None
  var _integer: (NamedRule | None) = None
  var _integer_dec: (NamedRule | None) = None
  var _integer_hex: (NamedRule | None) = None
  var _integer_bin: (NamedRule | None) = None
  var _float: (NamedRule | None) = None
  var _char: (NamedRule | None) = None
  var _char_escape: (NamedRule | None) = None
  var _char_unicode: (NamedRule | None) = None
  var _string: (NamedRule | None) = None
  var _string_regular: (NamedRule | None) = None
  var _string_triple: (NamedRule | None) = None

  new create(context: Context, trivia: TriviaBuilder, token: TokenBuilder,
    keyword: KeywordBuilder)
  =>
    _context = context
    _trivia = trivia
    _token = token
    _keyword = keyword

  fun ref literal(): NamedRule =>
    match _literal
    | let r: NamedRule => r
    else
      let literal' =
        recover val
          NamedRule("Literal",
            Disj([
              string()
              char()
              float()
              integer()
              bool()
            ]))
        end
      _literal = literal'
      literal'
    end

  fun ref bool(): NamedRule =>
    match _bool
    | let r: NamedRule => r
    else
      let trivia = _trivia.trivia()

      let lb' =
        recover val
          let post = Variable("post")

          NamedRule("Literal_Bool",
            _Build.with_post[ast.Trivia](
              recover
                Disj([
                  Literal(ast.Keywords.kwd_true())
                  Literal(ast.Keywords.kwd_false())
                ])
              end,
              trivia,
              {(r, _, b, p) =>
                let src_info = _Build.info(r)
                let string = src_info.literal_source()
                let true_str = ast.Keywords.kwd_true()
                let value =
                  string.compare_sub(true_str, true_str.size()) == Equal
                (ast.LiteralBool(_context, src_info, p, value), b)
              }
            ))
        end
      _bool = lb'
      lb'
    end

  fun ref integer(): NamedRule =>
    match _integer
    | let r: NamedRule => r
    else
      let trivia = _trivia.trivia()

      let li' =
        recover val
          let hex = Variable("hex")
          let bin = Variable("bin")
          let dec = Variable("dec")

          NamedRule("Literal_Integer",
            _Build.with_post[ast.Trivia](
              recover
                Disj([
                  Bind(hex, integer_hex())
                  Bind(bin, integer_bin())
                  Bind(dec, integer_dec())
                ])
              end,
              trivia,
              {(r, _, b, p) =>
                let kind =
                  if b.contains(hex) then
                    ast.HexadecimalInteger
                  elseif b.contains(bin) then
                    ast.BinaryInteger
                  else
                    ast.DecimalInteger
                  end

                (ast.LiteralInteger(_Build.info(r), p, kind), b)
              }
            ))
        end
      _integer = li'
      li'
    end

  fun ref integer_dec(): NamedRule =>
    match _integer_dec
    | let r: NamedRule => r
    else
      let li' =
        recover val
          NamedRule("Literal_Integer_Dec",
            Conj([
              Single(_Digits())
              Star(Single(_Digits.with_underscore()))
            ]))
        end
      _integer_dec = li'
      li'
    end

  fun ref integer_hex(): NamedRule =>
    match _integer_hex
    | let r: NamedRule => r
    else
      let li' =
        recover val
          NamedRule("Literal_Integer_Hex",
            Conj([
              Single("0")
              Single("xX")
              Disj([
                Plus(Single(_Hex.with_underscore()))
                Error(ErrorMsg.literal_integer_hex_empty())
              ])
            ]))
        end
      _integer_hex = li'
      li'
    end

  fun ref integer_bin(): NamedRule =>
    match _integer_bin
    | let r: NamedRule => r
    else
      let li' =
        recover val
          NamedRule("Literal_Integer_Bin",
            Conj([
              Single("0")
              Single("bB")
              Disj([
                Plus(Single(_Binary.with_underscore()))
                Error(ErrorMsg.literal_integer_bin_empty())
              ])
            ]))
        end
      _integer_bin = li'
      li'
    end

  fun ref float(): NamedRule =>
    match _float
    | let r: NamedRule => r
    else
      let trivia = _trivia.trivia()

      let lf' =
        recover val
          let int_part = Variable("int_part")
          let frac_part = Variable("frac_part")
          let exp_sign = Variable("exp_sign")
          let exponent = Variable("exponent")

          NamedRule("Literal_Float",
            _Build.with_post[ast.Trivia](
              recover
                Conj([
                  Bind(int_part, integer())
                  Ques(
                    Conj([
                      Single(ast.Tokens.decimal_point())
                      Bind(frac_part, integer())
                    ]))
                  Ques(
                    Conj([
                      Single("eE")
                      Bind(exp_sign,
                        Ques(
                          Single("-+"),
                          {(r, _, b) => (ast.Span(_Build.info(r)), b) }))
                      Bind(exponent, integer())
                    ]))
                ])
              end,
              trivia,
              this~_float_action(int_part, frac_part, exp_sign, exponent)
            ))
        end
      _float = lf'
      lf'
    end

  fun tag _float_action(
    int_part: Variable,
    frac_part: Variable,
    exp_sign: Variable,
    exponent: Variable,
    r: Success,
    c: ast.NodeSeq[ast.Node],
    b: Bindings,
    p: ast.Trivia)
    : ((ast.Node | None), Bindings)
  =>
    try
      let children' =
        recover val
          let children: Array[ast.Node] = Array[ast.Node](4)

          let ip = _Build.value(b, int_part)? as ast.LiteralInteger
          var next_info = ast.SrcInfo(r.data.locator(),
            ip.src_info().next(), ip.src_info().next())

          // we need to have 4 children, even if empty spans
          children.push(ip)
          try
            let fp = _Build.value(b, frac_part)? as ast.LiteralInteger
            next_info = ast.SrcInfo(r.data.locator(),
              fp.src_info().next(), fp.src_info().next())
            children.push(fp)
          else
            children.push(ast.Span(next_info))
          end

          try
            let es = _Build.value(b, exp_sign)?
            next_info = ast.SrcInfo(r.data.locator(),
              es.src_info().next(), es.src_info().next())
            children.push(es)
          else
            children.push(ast.Span(next_info))
          end

          try
            let ex = _Build.value(b, exponent)? as ast.LiteralInteger
            children.push(ex)
          else
            children.push(ast.Span(next_info))
          end

          children
        end
      (ast.LiteralFloat(_Build.info(r), children', p), b)
    else
      (ast.LiteralFloat.from(_Build.info(r), 0.0, true), b)
    end

  fun ref char(): NamedRule =>
    match _char
    | let r: NamedRule => r
    else
      let trivia = _trivia.trivia()

      let lc' =
        recover val
          NamedRule("Literal_Char",
            _Build.with_post[ast.Trivia](
              recover
                Conj([
                  Single(ast.Tokens.single_quote())
                  Disj([
                    Star(
                      Conj([
                        Neg(Single(ast.Tokens.single_quote()))
                        Disj([
                          char_escape()
                          Single("",
                            {(r, _, b) => (ast.Span(_Build.info(r)), b) })
                        ])
                      ]), 1)
                    Error(ErrorMsg.literal_char_empty())
                  ])
                  Disj([
                    Single(ast.Tokens.single_quote())
                    Error(ErrorMsg.literal_char_unterminated())
                  ])
                ])
              end,
              trivia,
              {(r, children, b, p) =>
                (ast.LiteralChar(_Build.info(r), children, p), b) }
            ))
        end
      _char = lc'
      lc'
    end

  fun ref char_escape(): NamedRule =>
    match _char_escape
    | let r: NamedRule => r
    else
      let lce' =
        recover val
          NamedRule("Literal_Char_Escape",
            Conj([
              Single(ast.Tokens.backslash())
              Disj([
                Disj([
                  Conj([
                    Single("xX")
                    Single(_Hex())
                    Single(_Hex())
                  ])
                  Single("abefnrtv\\0'\"")
                ])
                Error(ErrorMsg.literal_char_escape_invalid())
              ])
            ]),
            {(r, _, b) => (ast.LiteralCharEscape(_Build.info(r)), b) })
        end
      _char_escape = lce'
      lce'
    end

  fun ref char_unicode(): NamedRule =>
    match _char_unicode
    | let r: NamedRule => r
    else
      let lcu' =
        recover val
          NamedRule("Literal_Char_Escape_Unicode",
            Conj([
              Single(ast.Tokens.backslash())
              Disj([
                Conj([
                  Single("u")
                  Star(Single(_Hex()), 4, None, 4)
                ])
                Conj([
                  Single("U")
                  Star(Single(_Hex()), 6, None, 6)
                ])
                Error(ErrorMsg.literal_char_unicode_invalid())
              ])
            ]),
            {(r, _, b) => (ast.LiteralCharUnicode(_Build.info(r)), b) })
        end
      _char_unicode = lcu'
      lcu'
    end

  fun ref string(): NamedRule =>
    match _string
    | let r: NamedRule => r
    else
      let trivia = _trivia.trivia()

      let s' =
        recover val
          NamedRule("Literal_String",
            _Build.with_post[ast.Trivia](
              recover
                Disj([
                  string_triple()
                  string_regular()
                ])
              end,
              trivia,
              {(r, c, b, p) =>
                (ast.LiteralString(_context, _Build.info(r), c, p), b)
              }
            ))
        end
      _string = s'
      s'
    end

  fun ref string_regular(): NamedRule =>
    match _string_regular
    | let r: NamedRule => r
    else
      let sr' = _string_delim("Literal_String_Regular",
        _token.double_quote())
      _string_regular = sr'
      sr'
    end

  fun ref string_triple(): NamedRule =>
    match _string_triple
    | let r: NamedRule => r
    else
      let st' = _string_delim("Literal_String_Triple",
        _token.triple_double_quote())
      _string_triple = st'
      st'
    end

  fun ref _string_delim(name: String, delim: NamedRule): NamedRule =>
    recover val
      NamedRule(name,
        Conj([
          delim
          Star(
            Conj([
              Neg(delim)
              Disj([
                char_unicode()
                char_escape()
                Single("", {(r, _, b) => (ast.Span(_Build.info(r)), b) })
              ])
            ]))
          Disj([
            delim
            Error(ErrorMsg.literal_string_unterminated())
          ])
        ]))
    end
