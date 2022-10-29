use "collections"

use ast = "../ast"

class TriviaBuilder
  let _context: Context

  var _trivia: MapIs[USize, NamedRule] = MapIs[USize, NamedRule]

  var _post_trivia: (NamedRule | None) = None
  var _comment: (NamedRule | None) = None
  var _comment_line: (NamedRule | None) = None
  var _comment_nested: (NamedRule | None) = None
  var _ws: (NamedRule | None) = None
  var _eol: (NamedRule | None) = None
  var _dol: (NamedRule | None) = None
  var _eof: (NamedRule | None) = None

  new create(context: Context) =>
    _context = context

  fun ref trivia(min: USize = 0): NamedRule =>
    _trivia.get_or_else(min, _build_trivia(min))

  fun ref _build_trivia(min: USize): NamedRule =>
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
    _trivia(min) = trivia'
    trivia'

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
            Plus(Single(" \t")),
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
