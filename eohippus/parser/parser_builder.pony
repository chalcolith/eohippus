
use "kiuatan"
use "../ast"

class ParserBuilder[CH: ((U8 | U16) & Integer[CH])]
  let _context: ParserContext[CH]

  var _literal_bool: (Rule[CH, SrcNode[CH]] | None) = None

  var _ws: (Rule[CH, SrcNode[CH]] | None) = None
  var _eol: (Rule[CH, SrcNode[CH]] | None) = None
  var _eof: (Rule[CH, SrcNode[CH]] | None) = None

  new create(context: ParserContext[CH]) =>
    _context = context

  fun ref literal_bool(): Rule[CH, SrcNode[CH]] =>
    match _ws
    | let r: Rule[CH, SrcNode[CH]] => r
    else
      let lb' =
        recover val
          Rule[CH, SrcNode[CH]]("Literal_Bool",
            Disj[CH, SrcNode[CH]]([
              Literal[CH, SrcNode[CH]](ch_seq("true"),
                {(r, c, b) => (SrcLiteralBool[CH](r.start, r.next, true), b)})
              Literal[CH, SrcNode[CH]](ch_seq("false"),
                {(r, c, b) => (SrcLiteralBool[CH](r.start, r.next, false), b)})
            ])
          )
        end
      _literal_bool = lb'
      lb'
    end

  fun ref ws(): Rule[CH, SrcNode[CH]] =>
    match _ws
    | let r: Rule[CH, SrcNode[CH]] => r
    else
      let ws' =
        recover val
          Rule[CH, SrcNode[CH]]("WS",
            Star[CH, SrcNode[CH]](Single[CH, SrcNode[CH]](ch_seq(" \t")), 1,
              {(r, c, b) => (SrcTriviaWS[CH](r.start, r.next), b) }))
        end
      _ws = ws'
      ws'
    end

  fun ref eol(): Rule[CH, SrcNode[CH]] =>
    match _eol
    | let r: Rule[CH, SrcNode[CH]] => r
    else
      let eol' =
        recover val
          Rule[CH, SrcNode[CH]]("EOL",
            Disj[CH, SrcNode[CH]]([
              Literal[CH, SrcNode[CH]](ch_seq("\r\n"))
              Literal[CH, SrcNode[CH]](ch_seq("\n"))
              Literal[CH, SrcNode[CH]](ch_seq("\r"))
            ]),
            {(r, c, b) => (SrcTriviaEOL[CH](r.start, r.next), b) })
        end
      _eol = eol'
      eol'
    end

  fun ref eof(): Rule[CH, SrcNode[CH]] =>
    match _eof
    | let r: Rule[CH, SrcNode[CH]] => r
    else
      let eof' =
        recover val
          Rule[CH, SrcNode[CH]]("EOF",
            Neg[CH, SrcNode[CH]](Single[CH, SrcNode[CH]]),
            {(r, c, b) => (SrcTriviaEOL[CH](r.start, r.next), b) })
        end
      _eof = eof'
      eof'
    end

  fun ch_seq(str: String): ReadSeq[CH] val =>
    recover
      let result = Array[CH](str.size())
      for ch in str.values() do
        result.push(CH.from[U8](ch))
      end
      result
    end
