
use "ponytest"
use "promises"

use "kiuatan"
use "../eoh-ast"
use "../eoh-parser"

type CharParser is PonyParser[U8]
type CharParserResult is ParseResult[U8, AstNode[U8] val]
type CharParserResultOrError is
  ( CharParserResult val | ParseErrorMessage val | None)

class iso _TestFileItemSeq01Simple is UnitTest
  fun name(): String => "FileItem_Seq_01_Simple"
  fun label(): String => "FileItem"

  fun apply(h: TestHelper) =>
    let parser = CharParser.from_single_seq("a ")

    let promise = Promise[CharParserResultOrError]
    promise.next[None]({(result: CharParserResultOrError) =>
      match result
      | let r: CharParserResult val =>

        h.complete(true)
      | let m: ParseErrorMessage val =>
        h.fail(m)
      else
        h.fail()
      end
    })

    parser.parse(promise)

    h.long_test(1_000_000_000)
