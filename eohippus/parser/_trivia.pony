use ast = "../ast"

class _Trivia
  let _context: Context

  var _comment: (NamedRule | None) = None
  var _line_comment: (NamedRule | None) = None
  var _nested_comment: (NamedRule | None) = None
  var _ws: (NamedRule | None) = None
  var _eol: (NamedRule | None) = None
  var _eof: (NamedRule | None) = None

  new create(context: Context) =>
    _context = context

  fun ref comment(): NamedRule =>
    match _comment
    | let r: NamedRule => r
    else
      let comment' =
        recover val
          NamedRule("Comment",
            Disj([
              line_comment()
              nested_comment()
            ]))
        end
      _comment = comment'
      comment'
    end

  fun ref line_comment(): NamedRule =>
    match _line_comment
    | let r: NamedRule => r
    else
      // '//' (!EOL .)* EOL
      let line_comment' =
        recover val
          NamedRule("LineComment",
            Conj([
              Literal("//")
              Star(
                Conj([
                  Neg(Single("\r\n"))
                  Single()
                ]))
              Look(eol())
            ]),
            {(r, c, b) => (ast.TriviaLineComment(_Build.info(r)), b) })
        end
      _line_comment = line_comment'
      line_comment'
    end

  fun ref nested_comment(): NamedRule =>
    match _nested_comment
    | let r: NamedRule => r
    else
      // '/*' (!'*/' .)* '*/'
      let nested_comment' =
        recover val
          NamedRule("NestedComment",
            Conj([
              Literal("/*")
              Star(
                Conj([
                  Neg(Literal("*/"))
                  Single()
                ]))
              Literal("*/")
            ]),
            {(r, c, b) => (ast.TriviaNestedComment(_Build.info(r)), b) })
        end
      _nested_comment = nested_comment'
      nested_comment'
    end

  fun ref ws(): NamedRule =>
    match _ws
    | let r: NamedRule => r
    else
      let ws' =
        recover val
          NamedRule("WS",
            Star(Single(" \t"), 1),
            {(r, c, b) => (ast.TriviaWS(_Build.info(r)), b) })
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
            {(r, c, b) => (ast.TriviaEOL(_Build.info(r)), b) })
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
            {(r, c, b) => (ast.TriviaEOL(_Build.info(r)), b) })
        end
      _eof = eof'
      eof'
    end
