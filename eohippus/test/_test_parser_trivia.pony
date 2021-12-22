use "collections/persistent"
use "ponytest"

use ast = "../ast"
use parser = "../parser"

primitive _TestParserTrivia
  fun apply(test: PonyTest) =>
    test(_TestParserTriviaEOF)
    test(_TestParserTriviaEOL)
    test(_TestParserTriviaWS)
    test(_TestParserTriviaComment)

class iso _TestParserTriviaEOF is UnitTest
  fun name(): String => "parser/trivia/EOF"
  fun exclusion_group(): String => "parser/trivia"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.eof()

    let src1 = setup.src("")
    let loc1 = parser.Loc(src1)
    let inf1 = ast.SrcInfo(setup.data.locator(), loc1, loc1)
    let exp1 = recover ast.TriviaEOF(inf1) end

    let src2 = setup.src("a")

    _Assert.test_all(h, [
      _Assert.test_match(h, rule, src1, 0, setup.data, true, 0, exp1)
      _Assert.test_match(h, rule, src2, 0, setup.data, false)
    ])

class iso _TestParserTriviaEOL is UnitTest
  fun name(): String => "parser/trivia/EOL"
  fun exclusion_group(): String => "parser/trivia"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.eol()

    let src1 = setup.src(" \n ")
    let loc1 = parser.Loc(src1, 1)
    let inf1 = ast.SrcInfo(setup.data.locator(), loc1, loc1 + 1)
    let exp1 = recover ast.TriviaEOL(inf1) end

    let src2 = setup.src(" \r\n ")
    let loc2 = parser.Loc(src2, 1)
    let inf2 = ast.SrcInfo(setup.data.locator(), loc2, loc2 + 2)
    let exp2 = recover ast.TriviaEOL(inf2) end

    let src3 = setup.src(" \r ")
    let loc3 = parser.Loc(src3, 1)
    let inf3 = ast.SrcInfo(setup.data.locator(), loc3, loc3 + 1)
    let exp3 = recover ast.TriviaEOL(inf3) end

    let src4 = setup.src("")

    _Assert.test_all(h, [
      _Assert.test_match(h, rule, src1, 1, setup.data, true, 1, exp1)
      _Assert.test_match(h, rule, src1, 0, setup.data, false)

      _Assert.test_match(h, rule, src2, 1, setup.data, true, 2, exp2)
      _Assert.test_match(h, rule, src2, 3, setup.data, false)

      _Assert.test_match(h, rule, src3, 1, setup.data, true, 1, exp3)
      _Assert.test_match(h, rule, src3, 0, setup.data, false)

      _Assert.test_match(h, rule, src4, 0, setup.data, false)
    ])

class _TestParserTriviaWS is UnitTest
  fun name(): String => "parser/trivia/WS"
  fun exclusion_group(): String => "parser/trivia"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.ws()

    let src1 = setup.src(" \t")
    let loc1 = parser.Loc(src1)
    let inf1 = ast.SrcInfo(setup.data.locator(), loc1, loc1 + 2)
    let exp1 = recover ast.TriviaWS(inf1) end

    let src2 = setup.src("")

    _Assert.test_all(h, [
      _Assert.test_match(h, rule, src1, 0, setup.data, true, 2, exp1)
      _Assert.test_match(h, rule, src1, 2, setup.data, false)

      _Assert.test_match(h, rule, src2, 0, setup.data, false)
    ])

class _TestParserTriviaComment is UnitTest
  fun name(): String => "parser/trivia/Comment"
  fun exclusion_group(): String => "parser/trivia"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.comment()

    let src1 = setup.src("a // b c\n d")
    let loc1 = parser.Loc(src1, 2)
    let inf1 = ast.SrcInfo(setup.data.locator(), loc1, loc1 + 6)
    let exp1 = recover ast.TriviaLineComment(inf1) end

    let src2 = setup.src("a /* b * \n c / d */ e")
    let loc2 = parser.Loc(src2, 2)
    let inf2 = ast.SrcInfo(setup.data.locator(), loc2, loc2 + 17)
    let exp2 = recover ast.TriviaNestedComment(inf2) end

    _Assert.test_all(h, [
      _Assert.test_match(h, rule, src1, 2, setup.data, true, 6, exp1)
      _Assert.test_match(h, rule, src1, 0, setup.data, false)

      _Assert.test_match(h, rule, src2, 2, setup.data, true, 17, exp2)
      _Assert.test_match(h, rule, src2, 0, setup.data, false)
    ])
