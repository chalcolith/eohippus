
use "kiuatan"
use "../ast"

class Builder[CH: (U8 | U16)]
  let _context: Context[CH] box

  var _literal: (Rule[CH, AstNode[CH]] | None) = None
  var _literal_bool: (Rule[CH, AstNode[CH]] | None) = None

  var _space: (Rule[CH, AstNode[CH]] | None) = None
  var _eol: (Rule[CH, AstNode[CH]] | None) = None
  var _eof: (Rule[CH, AstNode[CH]] | None) = None

  new create(context: Context[CH]) =>
    _context = context

  fun ref space(): Role[CH, AstNode[CH]] =>
    match _space
    | let r: Rule[CH, [AstNode[CH]] => r
    else
      let space' =
        recover val
          Rule[CH, AstNode[CH]]("SPACE",

            Disj[CH, AstNode[CH]]([]))
    end

  fun ref eol(): Rule[CH, AstNode[CH]] =>
    match _eol
    | let r: Rule[CH, AstNode[CH]] => r
    else
      let eol' =
        recover val
          Rule[CH, AstNode[CH]]("EOL",
            Disj[CH, AstNode[CH]]([
              Literal[CH, AstNode[CH]]("\r\n")
              Literal[CH, AstNode[CH]]("\n")
              Literal[CH, AstNode[CH]]("\r")
            ]),
            {(r, c, b) =>
              (EOLNode(r.start, r.next), b)
            })
        end
      _eol = eol'
      eol'

  fun ref eof(): Rule[CH, AstNode[CH]] =>
    match _eof
    | let r: Rule[CH, AstNode[CH]] => r
    else
      let eof' =
        recover val
          Rule[CH, AstNode[CH]]("EOF",
            Neg[CH, AstNode[CH]](Sing[CH, AstNode[CH]]),
            {(r, c, b) =>
              (EOFNode(r.start, r.next), b)
            })
        end
      _eof = eof'
      eof'
    end
