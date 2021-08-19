use ast = "../ast"

class _Trivia
  let _context: Context

  var _ws: (NamedRule | None) = None
  var _eol: (NamedRule | None) = None
  var _eof: (NamedRule | None) = None

  new create(context: Context) =>
    _context = context

  fun ref ws(): NamedRule =>
    match _ws
    | let r: NamedRule => r
    else
      let ws' =
        recover val
          NamedRule("WS",
            Star(
              Single(" \t"),
              1,
              {(r, c, b) =>
                let info = ast.SrcInfo(r.data.locator(), r.start, r.next)
                (ast.TriviaWS(info), b)
              }))
        end
      _ws = ws'
      ws'
    end

  fun ref eol(): NamedRule =>
    match _eol
    | let r: NamedRule => r
    else
      let eol' =
        recover val
          NamedRule("EOL",
            Disj([
              Literal("\r\n")
              Literal("\n")
              Literal("\r")
            ]),
            {(r, c, b) =>
              let info = ast.SrcInfo(r.data.locator(), r.start, r.next)
              (ast.TriviaEOL(info), b)
            })
        end
      _eol = eol'
      eol'
    end

  fun ref eof(): NamedRule =>
    match _eof
    | let r: NamedRule => r
    else
      let eof' =
        recover val
          NamedRule("EOF",
            Neg(Single),
            {(r, c, b) =>
              let info = ast.SrcInfo(r.data.locator(), r.start, r.next)
              (ast.TriviaEOL(info), b)
            })
        end
      _eof = eof'
      eof'
    end
