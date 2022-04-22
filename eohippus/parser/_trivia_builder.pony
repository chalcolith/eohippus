use ast = "../ast"

class _TriviaBuilder
  let _context: Context
  let _token: _TokenBuilder

  var _trivia: (NamedRule | None) = None
  var _post_trivia: (NamedRule | None) = None
  var _comment: (NamedRule | None) = None
  var _comment_line: (NamedRule | None) = None
  var _comment_nested: (NamedRule | None) = None
  var _ws: (NamedRule | None) = None
  var _eol: (NamedRule | None) = None
  var _dol: (NamedRule | None) = None
  var _eof: (NamedRule | None) = None

  new create(context: Context, token: _TokenBuilder) =>
    _context = context
    _token = token

  fun ref trivia(min: USize = 0): NamedRule =>
    match _trivia
    | let r: NamedRule if min == 0 => r
    else
      let trivia' =
        recover val
          NamedRule("Trivia",
            Star(
              Disj([
                comment()
                ws()
                eol()
              ]), min),
            {(r, c, b) => (ast.Trivia(_Build.info(r), c), b)})
        end
      if min == 0 then
        _trivia = trivia'
      end
      trivia'
    end

  fun ref post_trivia(): NamedRule =>
    """Convenience for getting post-trivia including semi or EOL."""
    match _post_trivia
    | let r: NamedRule => r
    else
      let trivia' = trivia()
      let semicolon' = _token.glyph_semicolon()
      let eol' = eol()
      let post_trivia' =
        recover val
          NamedRule("PostTrivia",
            Star(
              Conj([
                Neg(Disj([semicolon'; eol']))
                trivia'
                Disj([semicolon'; eol'])
              ]) where min = 0, max = 1),
            {(r, c, b) => (ast.Trivia(_Build.info(r), c), b)})
        end
      _post_trivia = post_trivia'
      post_trivia'
    end

  fun ref comment(): NamedRule =>
    match _comment
    | let r: NamedRule => r
    else
      let comment' =
        recover val
          NamedRule("Comment",
            Disj([
              comment_line()
              comment_nested()
            ]))
        end
      _comment = comment'
      comment'
    end

  fun ref comment_line(): NamedRule =>
    match _comment_line
    | let r: NamedRule => r
    else
      // '//' (!EOL .)* EOL
      let comment_line' =
        recover val
          NamedRule("Comment_Line",
            Conj([
              Literal("//")
              Star(
                Conj([
                  Neg(Single("\r\n"))
                  Single()
                ]))
              Look(eol())
            ]),
            {(r, _, b) => (ast.TriviaLineComment(_Build.info(r)), b) })
        end
      _comment_line = comment_line'
      comment_line'
    end

  fun ref comment_nested(): NamedRule =>
    match _comment_nested
    | let r: NamedRule => r
    else
      // '/*' (!'*/' .)* '*/'
      let comment_nested' =
        recover val
          NamedRule("Comment_Nested",
            Conj([
              Literal("/*")
              Star(
                Conj([
                  Neg(Literal("*/"))
                  Single()
                ]))
              Literal("*/")
            ]),
            {(r, _, b) => (ast.TriviaNestedComment(_Build.info(r)), b) })
        end
      _comment_nested = comment_nested'
      comment_nested'
    end

  fun ref ws(): NamedRule =>
    match _ws
    | let r: NamedRule => r
    else
      let ws' =
        recover val
          NamedRule("WS",
            Star(Single(" \t"), 1),
            {(r, _, b) => (ast.TriviaWS(_Build.info(r)), b) })
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
            {(r, _, b) => (ast.TriviaEOL(_Build.info(r)), b) })
        end
      _eol = eol'
      eol'
    end

  fun ref dol(): NamedRule =>
    match _dol
    | let r: NamedRule => r
    else
      let dol' =
        recover val
          NamedRule("DOL", Conj([eol(); eol()]))
        end
      _dol = dol'
      dol'
    end

  fun ref eof(): NamedRule =>
    match _eof
    | let r: NamedRule => r
    else
      let eof' =
        recover val
          NamedRule("EOF",
            Neg(Single),
            {(r, _, b) => (ast.TriviaEOL(_Build.info(r)), b) })
        end
      _eof = eof'
      eof'
    end
