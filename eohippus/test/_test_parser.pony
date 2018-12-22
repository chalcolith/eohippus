
use "collections/persistent"
use "ponytest"

use "kiuatan"

use "../ast"
use "../parser"

class iso _TestParserEOF is UnitTest
  fun name(): String => "Test_Parser_EOF"

  fun apply(h: TestHelper) =>
    let context = ParserContext[U8]
    let builder = ParserBuilder[U8](context)
    let rule = builder.eof()

    let src1 = Lists[ReadSeq[U8] val].from([ "" ].values())
    let loc1 = Loc[U8](src1)

    let src2 = Lists[ReadSeq[U8] val].from([ "a" ].values())

    _Assert[U8].test_all(h, [
      _Assert[U8].test_match(h, rule, src1, 0, true, 0,
        recover SrcTriviaEOF[U8](loc1, loc1) end)
      _Assert[U8].test_match(h, rule, src2, 0, false)
    ])
