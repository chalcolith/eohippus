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
            Disj(
              [ string()
                char()
                float()
                integer()
                bool() ]))
        end
      _literal = literal'
      literal'
    end

  fun ref bool(): NamedRule =>
    match _bool
    | let r: NamedRule => r
    else
      let kwd_false = _keyword(ast.Keywords.kwd_false())
      let kwd_true = _keyword(ast.Keywords.kwd_true())
      let trivia = _trivia.trivia()

      let lb' =
        recover val
          let post = Variable("post")

          NamedRule("Literal_Bool",
            _Build.with_post[ast.Trivia](
              recover
                Disj(
                  [ kwd_true
                    kwd_false ])
              end,
              trivia,
              _LiteralActions~_bool()))
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
                Disj(
                  [ Bind(hex, integer_hex())
                    Bind(bin, integer_bin())
                    Bind(dec, integer_dec()) ])
              end,
              trivia,
              _LiteralActions~_integer(hex, bin, dec)))
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
                Conj(
                  [ Bind(int_part, integer())
                    Ques(
                      Conj(
                        [ Single(ast.Tokens.decimal_point())
                          Bind(frac_part, integer()) ]))
                    Ques(
                      Conj(
                        [ Single("eE")
                          Bind(exp_sign, Ques(Single("-+")))
                          Bind(exponent, integer()) ])) ])
              end,
              trivia,
              _LiteralActions~_float(int_part, frac_part, exp_sign, exponent)))
        end
      _float = lf'
      lf'
    end

  fun ref char(): NamedRule =>
    match _char
    | let r: NamedRule => r
    else
      let trivia = _trivia.trivia()
      let esc = Variable("esc")
      let uni = Variable("uni")
      let bod = Variable("bod")

      let lc' =
        recover val
          NamedRule("Literal_Char",
            _Build.with_post[ast.Trivia](
              recover
                Conj(
                  [ Single(ast.Tokens.single_quote())
                    Disj(
                      [ Bind(bod,
                          Star(
                            Conj(
                              [ Neg(Single(ast.Tokens.single_quote()))
                                Disj(
                                  [ Bind(esc, char_escape())
                                    Bind(uni, char_unicode())
                                    Single("") ]) ]),
                            1))
                        Error(ErrorMsg.literal_char_empty()) ])
                    Disj(
                      [ Single(ast.Tokens.single_quote())
                        Error(ErrorMsg.literal_char_unterminated()) ]) ])
              end,
              trivia,
              _LiteralActions~_char(bod, esc, uni)))
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
            Conj(
              [ Single(ast.Tokens.backslash())
                Disj(
                  [ Disj(
                      [ Conj(
                          [ Single("xX")
                            Single(_Hex())
                            Single(_Hex()) ])
                        Single("abefnrtv\\0'\"") ])
                    Error(ErrorMsg.literal_char_escape_invalid()) ]) ]))
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
            Conj(
              [ Single(ast.Tokens.backslash())
                Disj(
                  [ Conj(
                      [ Single("u")
                        Star(Single(_Hex()), 4, None, 4) ])
                    Conj(
                      [ Single("U")
                        Star(Single(_Hex()), 6, None, 6) ])
                    Error(ErrorMsg.literal_char_unicode_invalid()) ]) ]))
        end
      _char_unicode = lcu'
      lcu'
    end

  fun ref string(): NamedRule =>
    match _string
    | let r: NamedRule => r
    else
      let trivia = _trivia.trivia()

      let tri = Variable("tri")

      let s' =
        recover val
          NamedRule("Literal_String",
            _Build.with_post[ast.Trivia](
              recover
                Disj(
                  [ Bind(tri, string_triple())
                    string_regular() ])
              end,
              trivia,
              _LiteralActions~_string(tri)))
        end
      _string = s'
      s'
    end

  fun ref string_regular(): NamedRule =>
    match _string_regular
    | let r: NamedRule => r
    else
      let sr' = _string_delim(
        "Literal_String_Regular",
        _token(ast.Tokens.double_quote()))
      _string_regular = sr'
      sr'
    end

  fun ref string_triple(): NamedRule =>
    match _string_triple
    | let r: NamedRule => r
    else
      let st' = _string_delim(
        "Literal_String_Triple",
        _token(ast.Tokens.triple_double_quote()))
      _string_triple = st'
      st'
    end

  fun ref _string_delim(name: String, delim: NamedRule): NamedRule
  =>
    recover val
      NamedRule(name,
        Conj(
          [ delim
            Star(
              Conj(
                [ Neg(delim)
                  Disj(
                    [ char_unicode()
                      char_escape()
                      Plus(
                        Single(""),
                        {(r, c, b) =>
                          let value = ast.NodeWith[ast.Span](
                            _Build.info(r), c, ast.Span)
                          (value, b) }) ]) ]))
            Disj(
              [ delim
                Error(ErrorMsg.literal_string_unterminated()) ]) ]))
    end
