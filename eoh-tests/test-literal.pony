
use "ponytest"
use "promises"

use "kiuatan"
use "../eoh-ast"
use "../eoh-parser"


primitive _LiteralUtils
  fun assert_literal_bool(h: TestHelper, expected: Bool,
    result: CharParserResultOrError)
  =>
    let success =
      match result
      | let r: CharParserResult val =>
        match r.value()
        | let n: AstNodeLiteralBool[U8] val =>
          h.assert_eq[Bool](expected, n.value())
        else
          h.log("ast node is the wrong type")
          false
        end
      | let m: ParseErrorMessage val =>
        h.log("parse error " + m)
        false
      else
        h.log("parse failed")
        false
      end
    h.complete(success)


class iso _TestLiteral01Bool is UnitTest
  fun name(): String => "Literal_01_Bool_true"

  fun apply(h: TestHelper) =>
    let gctx = GrammarContext[U8]
    let grammar = GrammarExpressions[U8].literal_bool(gctx)

    let p_true = CharParser.from_single_seq(grammar, "true")
    let pr_true = Promise[CharParserResultOrError]
    pr_true.next[None](_LiteralUtils~assert_literal_bool(h, true))
    p_true.parse(pr_true)

    h.long_test(10_000_000_000)

class iso _TestLiteral02Bool is UnitTest
  fun name(): String => "Literal_02_Bool_false"

  fun apply(h: TestHelper) =>
    let gctx = GrammarContext[U8]
    let grammar = GrammarExpressions[U8].literal_bool(gctx)

    let p_false = CharParser.from_single_seq(grammar, "false")
    let pr_false = Promise[CharParserResultOrError]
    pr_false.next[None](_LiteralUtils~assert_literal_bool(h, false))
    p_false.parse(pr_false)

    h.long_test(10_000_000_000)

class iso _TestLiteral03Bool is UnitTest
  fun name(): String => "Literal_03_Bool_err"

  fun apply(h: TestHelper) =>
    let gctx = GrammarContext[U8]
    let grammar = GrammarExpressions[U8].literal_bool(gctx)

    let p_err = CharParser.from_single_seq(grammar, "foo")
    let pr_err = Promise[CharParserResultOrError]
    pr_err.next[None]({(result) =>
      match result
      | None =>
        h.complete(true)
      else
        h.log("parse succeeded where it should have failed")
        h.complete(false)
      end
    })
    p_err.parse(pr_err)

    h.long_test(10_000_000_000)
