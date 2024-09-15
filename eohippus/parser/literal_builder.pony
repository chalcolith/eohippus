use ast = "../ast"
use ".."

class LiteralBuilder
  let _context: Context
  let _trivia: TriviaBuilder
  let _token: TokenBuilder
  let _keyword: KeywordBuilder

  let literal: NamedRule = NamedRule("a literal")
  let bool: NamedRule = NamedRule("a literal Bool")
  let integer: NamedRule = NamedRule("an integer literal")
  let integer_dec: NamedRule = NamedRule("a decimal integer literal")
  let integer_hex: NamedRule = NamedRule("a hexadecimal integer literal")
  let integer_bin: NamedRule = NamedRule("a binary integer literal")
  let float: NamedRule = NamedRule("a floating-point literal")
  let char: NamedRule = NamedRule("a character literal")
  let char_escape: NamedRule = NamedRule("an escaped character")
  let char_unicode: NamedRule = NamedRule("a unicode character")
  let string: NamedRule = NamedRule("a string literal")
  let string_regular: NamedRule = NamedRule("a regular string literal")
  let string_triple: NamedRule = NamedRule("a triple-quoted string literal")

  new create(
    context: Context,
    trivia: TriviaBuilder,
    token: TokenBuilder,
    keyword: KeywordBuilder)
  =>
    _context = context
    _trivia = trivia
    _token = token
    _keyword = keyword

    _build_literal()
    _build_bool()
    _build_integer()
    _build_integer_dec()
    _build_integer_hex()
    _build_integer_bin()
    _build_float()
    _build_char()
    _build_char_escape()
    _build_char_unicode()
    _build_string()
    _build_string_regular()
    _build_string_triple()

  fun ref _build_literal() =>
    literal.set_body(
      Disj(
        [ string
          char
          float
          integer
          bool
        ]))

  fun ref _build_bool() =>
    bool.set_body(
      _Build.with_post[ast.Trivia](
        Disj(
          [ _keyword(ast.Keywords.kwd_false())
            _keyword(ast.Keywords.kwd_true()) ]),
        _trivia.trivia,
        _LiteralActions~_bool()))

  fun ref _build_integer() =>
    let hex = Variable("hex")
    let bin = Variable("bin")
    let dec = Variable("dec")

    integer.set_body(
      _Build.with_post[ast.Trivia](
        Disj(
          [ Bind(hex, integer_hex)
            Bind(bin, integer_bin)
            Bind(dec, integer_dec)
          ]),
        _trivia.trivia,
        _LiteralActions~_integer(hex, bin, dec)))

  fun ref _build_integer_dec() =>
    integer_dec.set_body(
      Conj(
        [ Single(_Digits())
          Star(Single(_Digits.with_underscore()))
        ]))

  fun ref _build_integer_hex() =>
    integer_hex.set_body(
      Conj(
        [ Single("0")
          Single("xX")
          Disj(
            [ Plus(Single(_Hex.with_underscore()))
              Error(ErrorMsg.literal_integer_hex_empty())
            ])
        ]))

  fun ref _build_integer_bin() =>
    integer_bin.set_body(
      Conj(
        [ Single("0")
          Single("bB")
          Disj(
            [ Plus(Single(_Binary.with_underscore()))
              Error(ErrorMsg.literal_integer_bin_empty())
            ])
        ]))

  fun ref _build_float() =>
    let int_part = Variable("int_part")
    let frac_part = Variable("frac_part")
    let exp_sign = Variable("exp_sign")
    let exponent = Variable("exponent")

    float.set_body(
      _Build.with_post[ast.Trivia](
        Conj(
          [ Bind(int_part, integer_dec)
            Ques(
              Conj(
                [ Single(ast.Tokens.decimal_point())
                  Bind(frac_part, integer_dec) ]))
            Ques(
              Conj(
                [ Single("eE")
                  Bind(exp_sign, Ques(Single("-+")))
                  Bind(exponent, integer_dec) ])) ]),
        _trivia.trivia,
        _LiteralActions~_float(int_part, frac_part, exp_sign, exponent)))

  fun ref _build_char() =>
    let esc = Variable("esc")
    let uni = Variable("uni")
    let bod = Variable("bod")

    char.set_body(
      _Build.with_post[ast.Trivia](
        Conj(
          [ Single(ast.Tokens.single_quote())
            Disj(
              [ Bind(
                  bod,
                  Star(
                    Conj(
                      [ Neg(Single(ast.Tokens.single_quote()))
                        Disj(
                          [ Bind(uni, char_unicode)
                            Bind(esc, char_escape)
                            Single("")
                          ])
                      ])
                    where min' = 1))
                Error(ErrorMsg.literal_char_empty())
              ])
            Disj(
              [ Single(ast.Tokens.single_quote())
                Error(ErrorMsg.literal_char_unterminated())
              ])
          ]),
        _trivia.trivia,
        _LiteralActions~_char(bod, uni, esc)))

  fun ref _build_char_escape() =>
    char_escape.set_body(
      Conj(
        [ Single(ast.Tokens.backslash())
          Disj(
            [ Disj(
                [ Conj(
                    [ Single("xX")
                      Single(_Hex())
                      Single(_Hex())
                    ])
                  Single("abefnrtv\\0'\"")
                ])
              Error(ErrorMsg.literal_char_escape_invalid())
            ])
        ]))

  fun ref _build_char_unicode() =>
    char_unicode.set_body(
      Conj(
        [ Single(ast.Tokens.backslash())
          Disj(
            [ Conj(
                [ Single("u")
                  Disj(
                    [ Star(Single(_Hex()), 4, None, 4)
                      Error(ErrorMsg.literal_char_unicode_invalid())
                    ])
                ])
              Conj(
                [ Single("U")
                  Disj(
                    [ Star(Single(_Hex()), 6, None, 6)
                      Error(ErrorMsg.literal_char_unicode_invalid())
                    ])
                ])
            ])
        ]))

  fun ref _build_string() =>
    let tri = Variable("tri")
    let reg = Variable("reg")
    string.set_body(
      _Build.with_post[ast.Trivia](
        Disj(
          [ Bind(tri, string_triple)
            Bind(reg, string_regular) ]),
        _trivia.trivia,
        _LiteralActions~_string(tri, reg)))

  fun ref _build_string_regular() =>
    // we don't want to include post trivia
    string_regular.set_body(
      _string_delim(
        Literal(
          ast.Tokens.double_quote(),
          {(d, r, c, b) =>
            let string =
              recover val
                String .> concat(r.start.values(r.next))
              end
            let span = ast.NodeWith[ast.Span](_Build.info(d, r), [], ast.Span)
            let value = ast.NodeWith[ast.Token](
              _Build.info(d, r), [ span ], ast.Token(string))
            (value, b)
          })))

  fun ref _build_string_triple() =>
    // we don't want to include post trivia
    string_triple.set_body(
      _string_delim(
        Literal(
          ast.Tokens.triple_double_quote(),
          {(d, r, c, b) =>
            let string =
              recover val
                String .> concat(r.start.values(r.next))
              end
            let span = ast.NodeWith[ast.Span](_Build.info(d, r), [], ast.Span)
            let value = ast.NodeWith[ast.Token](
              _Build.info(d, r), [ span ], ast.Token(string))
            (value, b)
          })))

  fun _string_delim(delim: RuleNode): RuleNode =>
    Conj(
      [ delim
        Star(
          Conj(
            [ Neg(delim)
              Disj(
                [ _trivia.eol
                  _string_char_uni()
                  _string_char_esc()
                  Star(
                    Conj(
                      [ Neg(delim)
                        Neg(_trivia.eol)
                        Neg(Single(ast.Tokens.backslash()))
                        Single()
                      ]),
                    1,
                    {(d, r, c, b) =>
                      ( ast.NodeWith[ast.Span](
                        _Build.info(d, r), c, ast.Span)
                        , b )
                    })
                ])
            ]))
        Disj(
          [ delim
            Error(ErrorMsg.literal_string_unterminated())
          ])
      ])

  fun _string_char_uni(): RuleNode =>
    Conj(
      [ char_unicode ],
      {(d, r, c, b) => (_LiteralActions._char_uni(d, r, r, c, []), b) })

  fun _string_char_esc(): RuleNode =>
    Conj(
      [ char_escape ],
      {(d, r, c, b) => (_LiteralActions._char_esc(d, r, r, c, []), b) })
