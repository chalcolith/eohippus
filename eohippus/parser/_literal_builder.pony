use ast = "../ast"
use ".."

class _LiteralBuilder
  let _context: Context
  let _glyph: _GlyphBuilder

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

  new create(context: Context, glyph: _GlyphBuilder) =>
    _context = context
    _glyph = glyph

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
      let lb' =
        recover val
          NamedRule("Literal_Bool",
            Disj([
              Literal(
                "true",
                {(r, _, b) =>
                  (ast.LiteralBool(_context, _Build.info(r), true), b)
                })
              Literal(
                "false",
                {(r, _, b) =>
                  (ast.LiteralBool(_context, _Build.info(r), false), b)
                })
            ]))
        end
      _bool = lb'
      lb'
    end

  fun ref integer(): NamedRule =>
    match _integer
    | let r: NamedRule => r
    else
      let li' =
        recover val
          NamedRule("Literal_Integer",
            Disj([
              integer_hex()
              integer_bin()
              integer_dec()
            ]))
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
              Single("0123456789")
              Star(Single("0123456789_"))
            ]),
            {(r, _, b) =>
              (ast.LiteralInteger(_Build.info(r), ast.DecimalInteger), b)
            })
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
                Star(Single("0123456789abcdefABCDEF_"), 1)
                Error(ErrorMsg.literal_integer_hex_empty())
              ])
            ]),
            {(r, _, b) =>
              (ast.LiteralInteger(_Build.info(r), ast.HexadecimalInteger), b)
            })
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
                Star(Single("01_"), 1)
                Error(ErrorMsg.literal_integer_bin_empty())
              ])
            ]),
            {(r, _, b) =>
              (ast.LiteralInteger(_Build.info(r), ast.BinaryInteger), b)
            })
        end
      _integer_bin = li'
      li'
    end

  fun ref float(): NamedRule =>
    match _float
    | let r: NamedRule => r
    else
      let int_part = Variable
      let frac_part = Variable
      let exp_sign = Variable
      let exponent = Variable

      let lf' =
        recover val
          NamedRule("Literal_Float",
            Conj([
              Bind(int_part, integer())
              Star(
                Conj([
                  Single(".")
                  Bind(frac_part, integer())
                ]),
                0, None, 1)
              Star(
                Conj([
                  Single("eE")
                  Bind(exp_sign,
                    Star(
                      Single("-+"),
                      0,
                      {(r, _, b) => (ast.Span(_Build.info(r)), b) },
                      1))
                  Bind(exponent, integer())
                ]),
                0, None, 1)
            ]),
            {(r, _, b) =>
              try
                let children' =
                  recover val
                    let children: Array[ast.Node] = Array[ast.Node](4)
                    let ip = b(int_part)?._2 as ast.LiteralInteger
                    var next_info = ast.SrcInfo(r.data.locator(),
                      ip.src_info().next(), ip.src_info().next())

                    // we need to have 4 children, even if empty spans
                    children.push(ip)
                    match try b(frac_part)? end
                    | (_, let fp: ast.LiteralInteger) =>
                      next_info = ast.SrcInfo(r.data.locator(),
                        fp.src_info().next(), fp.src_info().next())
                      children.push(fp)
                    else
                      children.push(ast.Span(next_info))
                    end
                    match try b(exp_sign)? end
                    | (_, let es: ast.Node) =>
                      next_info = ast.SrcInfo(r.data.locator(),
                        es.src_info().next(), es.src_info().next())
                      children.push(es)
                    else
                      children.push(ast.Span(next_info))
                    end
                    match try b(exponent)? end
                    | (_, let ex: ast.LiteralInteger) =>
                      children.push(ex)
                    else
                      children.push(ast.Span(next_info))
                    end
                    children
                  end
                (ast.LiteralFloat(_Build.info(r), children'), b)
              else
                (ast.LiteralFloat.from(_Build.info(r), 0.0, true), b)
              end
            })
        end
      _float = lf'
      lf'
    end

  fun ref char(): NamedRule =>
    match _char
    | let r: NamedRule => r
    else
      let lc' =
        recover val
          NamedRule("Literal_Char",
            Conj([
              Single("'")
              Disj([
                Star(
                  Conj([
                    Neg(Single("'"))
                    Disj([
                      char_escape()
                      Single("", {(r, _, b) => (ast.Span(_Build.info(r)), b) })
                    ])
                  ]), 1)
                Error(ErrorMsg.literal_char_empty())
              ])
              Disj([
                Single("'")
                Error(ErrorMsg.literal_char_unterminated())
              ])
            ]),
            {(r, children, b) =>
              (ast.LiteralChar(_Build.info(r), children), b) })
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
              Single("\\")
              Disj([
                Disj([
                  Conj([
                    Single("xX")
                    Single("0123456789abcdefABCDEF")
                    Single("0123456789abcdefABCDEF")
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
              Single("\\")
              Single("uU")
              Disj([
                Star(Single("0123456789abcdefABCDEF"), 4, None, 4)
                Star(Single("0123456789abcdefABCDEF"), 6, None, 6)
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
      let s' =
        recover val
          NamedRule("Literal_String",
            Disj([
              string_triple()
              string_regular()
            ]),
            {(r, c, b) => (ast.LiteralString(_context, _Build.info(r), c), b) })
        end
      _string = s'
      s'
    end

  fun ref string_regular(): NamedRule =>
    match _string_regular
    | let r: NamedRule => r
    else
      let sr' = _string_delim("Literal_String_Regular", _glyph.double_quote())
      _string_regular = sr'
      sr'
    end

  fun ref string_triple(): NamedRule =>
    match _string_triple
    | let r: NamedRule => r
    else
      let st' = _string_delim("Literal_String_Triple",
        _glyph.triple_double_quote())
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
          delim
        ]))
    end
