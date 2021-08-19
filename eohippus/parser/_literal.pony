use "kiuatan"
use "../ast"

class _Literal[CH: ((U8 | U16) & UnsignedInteger[CH])]
  let _context: ParserContext[CH]

  var _literal_bool: (NamedRule[CH, ParserData[CH], AstNode[CH]] | None) = None

  new create(context: ParserContext[CH]) =>
    _context = context

  fun ref bool(): NamedRule[CH, ParserData[CH], AstNode[CH]] =>
    match _literal_bool
    | let r: NamedRule[CH, ParserData[CH], AstNode[CH]] => r
    else
      let lb' =
        recover val
          NamedRule[CH, ParserData[CH], AstNode[CH]]("Literal_Bool",
            Disj[CH, ParserData[CH], AstNode[CH]]([
              Literal[CH, ParserData[CH], AstNode[CH]](
                _Utils.ch_seq[CH]("true"),
                {(r, c, b) =>
                  let info = SrcInfo[CH](r.data.locator(), r.start, r.next)
                  (AstLiteralBool[CH](_context, info, true), b)
                })
              Literal[CH, ParserData[CH], AstNode[CH]](
                _Utils.ch_seq[CH]("false"),
                {(r, c, b) =>
                  let info = SrcInfo[CH](r.data.locator(), r.start, r.next)
                  (AstLiteralBool[CH](_context, info, false), b)
                })
            ])
          )
        end
      _literal_bool = lb'
      lb'
    end
