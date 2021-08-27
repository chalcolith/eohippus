use ast = "../ast"
use ".."

class _Literal
  let _context: Context

  var _literal_bool: (NamedRule | None) = None
  var _literal_integer: (NamedRule | None) = None
  var _literal_integer_dec: (NamedRule | None) = None
  var _literal_integer_hex: (NamedRule | None) = None
  var _literal_integer_bin: (NamedRule | None) = None
  var _literal_float: (NamedRule | None) = None

  new create(context: Context) =>
    _context = context

  fun ref bool(): NamedRule =>
    match _literal_bool
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
      _literal_bool = lb'
      lb'
    end

  fun ref integer(): NamedRule =>
    match _literal_integer
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
      _literal_integer = li'
      li'
    end

  fun ref integer_dec(): NamedRule =>
    match _literal_integer_dec
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
      _literal_integer_dec = li'
      li'
    end

  fun ref integer_hex(): NamedRule =>
    match _literal_integer_hex
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
      _literal_integer_hex = li'
      li'
    end

  fun ref integer_bin(): NamedRule =>
    match _literal_integer_bin
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
      _literal_integer_bin = li'
      li'
    end

  fun ref float(): NamedRule =>
    match _literal_float
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
                  Star(
                    Bind(exp_sign,
                      Single("-+",
                        {(r, _, b) => (ast.Span(_Build.info(r)), b) })),
                    0, None, 1)
                  Bind(exponent, integer())
                ]),
                0, None, 1)
            ]),
            {(r, _, b) =>
              try
                let children' =
                  recover val
                    let children: Array[ast.Node] = Array[ast.Node](4)
                    children.push(b(int_part)?._2 as ast.LiteralInteger)
                    children.push(b(frac_part)?._2 as ast.LiteralInteger)
                    match try b(exp_sign)? end
                    | (_, let es: ast.Node) => children.push(es)
                    end
                    match try b(exponent)? end
                    | (_, let ex: ast.LiteralInteger) => children.push(ex)
                    end
                    children
                  end
                (ast.LiteralFloat(_Build.info(r), children'), b)
              else
                (ast.LiteralFloat.from(_Build.info(r), 0.0, true), b)
              end
            })
        end
      _literal_float = lf'
      lf'
    end
