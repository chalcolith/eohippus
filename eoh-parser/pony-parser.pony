
use "collections"
use "promises"

use "kiuatan"
use "../eoh-ast"

actor PonyParser[CH: EohInput val]
  let _grammar: ParseRule[CH, AstNode[CH] val] val = PonyGrammar[CH].build()
  var _memo: ParseState[CH, AstNode[CH] val]

  new create(source: List[ReadSeq[CH] box] iso) =>
    _memo = ParseState[CH, AstNode[CH] val](consume source)

  new from_single_seq(seq: ReadSeq[CH] val) =>
    let source = List[ReadSeq[CH] box].from([as ReadSeq[CH] box: seq])
    _memo = ParseState[CH, AstNode[CH] val](source)

  be parse(p: Promise[
    (ParseResult[CH, AstNode[CH] val] val | ParseErrorMessage val | None)],
    clear_memo: Bool = false)
  =>
    if clear_memo then
      _memo = ParseState[CH, AstNode[CH] val](_memo.source())
    end
    p(_memo.parse(_grammar))
