use "collections/persistent"
use "ponytest"

use "kiuatan"

use "../ast"
use "../parser"
use "../types"

class _TestTriviaSetup
  let context: ParserContext[U8]
  let builder: ParserBuilder[U8]
  let data: ParserData[U8]

  new create(name: String) =>
    context = ParserContext[U8](recover Array[AstPackage[U8] val] end)
    builder = ParserBuilder[U8](context)
    data = ParserData[U8](name)

  fun src(str: String): List[ReadSeq[U8] val] =>
    Lists[ReadSeq[U8] val]([ str ])

class iso _TestParserTriviaEOF is UnitTest
  fun name(): String => "parser/trivia/EOF"
  fun exclusion_group(): String => "parser/trivia"

  fun apply(h: TestHelper) =>
    let setup = _TestTriviaSetup(name())
    let rule = setup.builder.eof()

    let src1 = setup.src("")
    let loc1 = Loc[U8](src1)
    let inf1 = SrcInfo[U8](setup.data.locator(), loc1, loc1)
    let exp1 = recover AstTriviaEOF[U8](inf1) end

    let src2 = setup.src("a")

    _Assert[U8].test_all(h, [
      _Assert[U8].test_match(h, rule, src1, 0, setup.data, true, 0, exp1)
      _Assert[U8].test_match(h, rule, src2, 0, setup.data, false)
    ])

class iso _TestParserTriviaEOL is UnitTest
  fun name(): String => "parser/trivia/EOL"
  fun exclusion_group(): String => "parser/trivia"

  fun apply(h: TestHelper) =>
    let setup = _TestTriviaSetup(name())
    let rule = setup.builder.eol()

    let src1 = setup.src(" \n ")
    let loc1 = Loc[U8](src1, 1)
    let inf1 = SrcInfo[U8](setup.data.locator(), loc1, loc1 + 1)
    let exp1 = recover AstTriviaEOL[U8](inf1) end

    let src2 = setup.src(" \r\n ")
    let loc2 = Loc[U8](src2, 1)
    let inf2 = SrcInfo[U8](setup.data.locator(), loc2, loc2 + 2)
    let exp2 = recover AstTriviaEOL[U8](inf2) end

    let src3 = setup.src(" \r ")
    let loc3 = Loc[U8](src3, 1)
    let inf3 = SrcInfo[U8](setup.data.locator(), loc3, loc3 + 1)
    let exp3 = recover AstTriviaEOL[U8](inf3) end

    let src4 = setup.src("")

    _Assert[U8].test_all(h, [
      _Assert[U8].test_match(h, rule, src1, 1, setup.data, true, 1, exp1)
      _Assert[U8].test_match(h, rule, src1, 0, setup.data, false)

      _Assert[U8].test_match(h, rule, src2, 1, setup.data, true, 2, exp2)
      _Assert[U8].test_match(h, rule, src2, 3, setup.data, false)

      _Assert[U8].test_match(h, rule, src3, 1, setup.data, true, 1, exp3)
      _Assert[U8].test_match(h, rule, src3, 0, setup.data, false)

      _Assert[U8].test_match(h, rule, src4, 0, setup.data, false)
    ])

class _TestParserTriviaWS is UnitTest
  fun name(): String => "parser/trivia/WS"
  fun exclusion_group(): String => "parser/trivia"

  fun apply(h: TestHelper) =>
    let setup = _TestTriviaSetup(name())
    let rule = setup.builder.ws()

    let src1 = setup.src(" \t")
    let loc1 = Loc[U8](src1)
    let inf1 = SrcInfo[U8](setup.data.locator(), loc1, loc1 + 2)
    let exp1 = recover AstTriviaWS[U8](inf1) end

    let src2 = setup.src("")

    _Assert[U8].test_all(h, [
      _Assert[U8].test_match(h, rule, src1, 0, setup.data, true, 2, exp1)
      _Assert[U8].test_match(h, rule, src1, 2, setup.data, false)

      _Assert[U8].test_match(h, rule, src2, 0, setup.data, false)
    ])
