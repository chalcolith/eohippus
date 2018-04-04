
use "collections"
use "promises"

use "kiuatan"
use "../eoh-ast"

actor PonyParser[CH: (Unsigned & Integer[CH])]
  let _grammar: ParseRule[CH, AstNode[CH] val] val
  var _memo: ParseState[CH, AstNode[CH] val]

  new create(grammar: ParseRule[CH, AstNode[CH] val] val,
    source: List[ReadSeq[CH] box] iso)
  =>
    _grammar = grammar
    _memo = ParseState[CH, AstNode[CH] val](consume source)

  new from_single_seq(grammar: ParseRule[CH, AstNode[CH] val] val,
    seq: ReadSeq[CH] val)
  =>
    _grammar = grammar
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
