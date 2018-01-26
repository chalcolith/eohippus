
use "kiuatan"
use "promises"
use "../eoh-ast"

actor PonyParser[CH: (U8 | U16)]
  let _source: List[ReadSeq[CH] box] box
  let _grammar: PonyGrammar[CH, AstNode[CH] val] box =
    PonyGrammar[CH, AstNode[CH] val]
  var _memo: ParseState[CH, AstNode[CH] val] =
    ParseState[CH, AstNode[CH] val](_source)

  new create(source: List[ReadSeq[CH] box] box) =>
    _source = source

  new from_single_seq(seq: ReadSeq[CH] box) =>
    _source = List[ReadSeq[CH] box].from([as ReadSeq[CH] box: seq])

  be parse(p: Promise[ParseResult[CH, AstNode[CH] val] val],
    clear_memo: bool = false)
  =>
    if clear_memo then
      _memo = ParseState[CH, AstNode[CH] val](source)
    end
    p(_memo.parse(_grammar))
