
use "ponytest"
use "promises"

use "kiuatan"
use "../eoh-ast"
use "../eoh-parser"

class iso _TestLiteral01Bool is UnitTest
  fun name(): String => "Literal_01_Bool"

  fun apply(h: TestHelper) =>
    let gctx = GrammarContext[U8]
    let grammar = GrammarExpressions[U8].literal_bool(gctx)

    let p_true = CharParser.from_single_seq(grammar, "true")
    let pr_true = Promise[CharParserResultOrError]
    pr_true.next[None]({(result) =>
      let success =
        match result
        | let r: CharParserResult val =>
          match r.value()
          | let n: AstNodeLiteralBool[U8] val =>
            match n.value()
            | true =>
              true
            | false =>
              h.log("ast node is false")
              false
            else
              false
            end
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
    })

    p_true.parse(pr_true)

    h.long_test(10_000_000_000)
