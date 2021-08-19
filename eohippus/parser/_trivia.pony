use "kiuatan"
use "../ast"

class _Trivia[CH: ((U8 | U16) & UnsignedInteger[CH])]
  let _context: ParserContext[CH]

  var _ws: (NamedRule[CH, ParserData[CH], AstNode[CH]] | None) = None
  var _eol: (NamedRule[CH, ParserData[CH], AstNode[CH]] | None) = None
  var _eof: (NamedRule[CH, ParserData[CH], AstNode[CH]] | None) = None

  new create(context: ParserContext[CH]) =>
    _context = context

  fun ref ws(): NamedRule[CH, ParserData[CH], AstNode[CH]] =>
    match _ws
    | let r: NamedRule[CH, ParserData[CH], AstNode[CH]] => r
    else
      let ws' =
        recover val
          NamedRule[CH, ParserData[CH], AstNode[CH]]("WS",
            Star[CH, ParserData[CH], AstNode[CH]](
              Single[CH, ParserData[CH], AstNode[CH]](_Utils.ch_seq[CH](" \t")),
              1,
              {(r, c, b) =>
                let info = SrcInfo[CH](r.data.locator(), r.start, r.next)
                (AstTriviaWS[CH](info), b)
              }))
        end
      _ws = ws'
      ws'
    end

  fun ref eol(): NamedRule[CH, ParserData[CH], AstNode[CH]] =>
    match _eol
    | let r: NamedRule[CH, ParserData[CH], AstNode[CH]] => r
    else
      let eol' =
        recover val
          NamedRule[CH, ParserData[CH], AstNode[CH]]("EOL",
            Disj[CH, ParserData[CH], AstNode[CH]]([
              Literal[CH, ParserData[CH], AstNode[CH]](
                _Utils.ch_seq[CH]("\r\n"))
              Literal[CH, ParserData[CH], AstNode[CH]](_Utils.ch_seq[CH]("\n"))
              Literal[CH, ParserData[CH], AstNode[CH]](_Utils.ch_seq[CH]("\r"))
            ]),
            {(r, c, b) =>
              let info = SrcInfo[CH](r.data.locator(), r.start, r.next)
              (AstTriviaEOL[CH](info), b) })
        end
      _eol = eol'
      eol'
    end

  fun ref eof(): NamedRule[CH, ParserData[CH], AstNode[CH]] =>
    match _eof
    | let r: NamedRule[CH, ParserData[CH], AstNode[CH]] => r
    else
      let eof' =
        recover val
          NamedRule[CH, ParserData[CH], AstNode[CH]]("EOF",
            Neg[CH, ParserData[CH], AstNode[CH]](
              Single[CH, ParserData[CH], AstNode[CH]]),
            {(r, c, b) =>
              let info = SrcInfo[CH](r.data.locator(), r.start, r.next)
              (AstTriviaEOL[CH](info), b)
            })
        end
      _eof = eof'
      eof'
    end
