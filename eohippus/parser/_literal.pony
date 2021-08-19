use ast = "../ast"

class _Literal
  let _context: Context

  var _literal_bool: (NamedRule | None) = None

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
                {(r, c, b) =>
                  let info = ast.SrcInfo(r.data.locator(), r.start, r.next)
                  (ast.LiteralBool(_context, info, true), b)
                })
              Literal(
                "false",
                {(r, c, b) =>
                  let info = ast.SrcInfo(r.data.locator(), r.start, r.next)
                  (ast.LiteralBool(_context, info, false), b)
                })
            ])
          )
        end
      _literal_bool = lb'
      lb'
    end
