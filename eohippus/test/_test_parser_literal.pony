use "collections/persistent"
use "ponytest"

use ast = "../ast"
use parser = "../parser"
use ".."

primitive TestParserLiteral
  fun apply(test: PonyTest) =>
    test(_TestParserLiteralBool)
    test(_TestParserLiteralIntegerDec)
    test(_TestParserLiteralIntegerHex)
    test(_TestParserLiteralIntegerBin)
    test(_TestParserLiteralFloat)
    test(_TestParserLiteralChar)
    test(_TestParserLiteralStringRegular)
    test(_TestParserLiteralStringTriple)

class iso _TestParserLiteralBool is UnitTest
  fun name(): String => "parser/literal/Bool"
  fun exclusion_group(): String => "parser/literal"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.literal_bool()

    let src1 = setup.src("true")
    let loc1 = parser.Loc(src1)
    let inf1 = ast.SrcInfo(setup.data.locator(), loc1, loc1 + 4)
    let exp1 = ast.LiteralBool(setup.context, inf1, true)

    let src2 = setup.src("false")
    let loc2 = parser.Loc(src2)
    let inf2 = ast.SrcInfo(setup.data.locator(), loc2, loc2 + 5)
    let exp2 = ast.LiteralBool(setup.context, inf2, false)

    let src3 = setup.src("foo")
    let src4 = setup.src("")

    _Assert.test_all(h, [
      _Assert.test_match(h, rule, src1, 0, setup.data, true, 4, exp1)
      _Assert.test_match(h, rule, src1, 1, setup.data, false)
      _Assert.test_match(h, rule, src2, 0, setup.data, true, 5, exp2)
      _Assert.test_match(h, rule, src3, 0, setup.data, false)
      _Assert.test_match(h, rule, src4, 0, setup.data, false)
    ])

class iso _TestParserLiteralIntegerDec is UnitTest
  fun name(): String => "parser/literal/Integer/Decimal"
  fun exclusion_group(): String => "parser/literal"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.literal_integer()

    let src1 = setup.src("1_234")
    let loc1 = parser.Loc(src1)
    let inf1 = ast.SrcInfo(setup.data.locator(), loc1, loc1 + 5)
    let exp1 = ast.LiteralInteger.from(inf1, ast.DecimalInteger, 1234)

    _Assert.test_all(h, [
      _Assert.test_match(h, rule, src1, 0, setup.data, true, 5, exp1)
    ])

class iso _TestParserLiteralIntegerHex is UnitTest
  fun name(): String => "parser/literal/Integer/Hexadecimal"
  fun exclusion_group(): String => "parser/literal"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.literal_integer()

    let src1 = setup.src("0x12_3abc")
    let loc1 = parser.Loc(src1)
    let inf1 = ast.SrcInfo(setup.data.locator(), loc1, loc1 + 9)
    let exp1 = ast.LiteralInteger.from(inf1, ast.HexadecimalInteger, 1194684)

    _Assert.test_all(h, [
      _Assert.test_match(h, rule, src1, 0, setup.data, true, 9, exp1)
    ])

class iso _TestParserLiteralIntegerBin is UnitTest
  fun name(): String => "parser/literal/Integer/Binary"
  fun exclusion_group(): String => "parser/literal"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.literal_integer()

    let src1 = setup.src("0b100101110101")
    let loc1 = parser.Loc(src1)
    let inf1 = ast.SrcInfo(setup.data.locator(), loc1, loc1 + 14)
    let exp1 = ast.LiteralInteger.from(inf1, ast.BinaryInteger, 2421)

    _Assert.test_all(h, [
      _Assert.test_match(h, rule, src1, 0, setup.data, true, 14, exp1)
    ])

class iso _TestParserLiteralFloat is UnitTest
  fun name(): String => "parser/literal/Float"
  fun exclusion_group(): String => "parser/literal"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.literal_float()

    let src1 = setup.src("123.456e-42")
    let loc1 = parser.Loc(src1)
    let inf1 = ast.SrcInfo(setup.data.locator(), loc1, loc1 + 11)
    let exp1 = ast.LiteralFloat.from(inf1, 1.23456e-40)

    let src2 = setup.src("23.45e67")
    let loc2 = parser.Loc(src2)
    let inf2 = ast.SrcInfo(setup.data.locator(), loc2, loc2 + 8)
    let exp2 = ast.LiteralFloat.from(inf2, 2.345e68)

    let src3 = setup.src("345.678")
    let loc3 = parser.Loc(src3)
    let inf3 = ast.SrcInfo(setup.data.locator(), loc3, loc3 + 7)
    let exp3 = ast.LiteralFloat.from(inf3, 345.678)

    let src4 = setup.src("456")
    let loc4 = parser.Loc(src4)
    let inf4 = ast.SrcInfo(setup.data.locator(), loc4, loc4 + 3)
    let exp4 = ast.LiteralFloat.from(inf4, 456.0)

    _Assert.test_all(h, [
      _Assert.test_match(h, rule, src1, 0, setup.data, true, 11, exp1)
      _Assert.test_match(h, rule, src2, 0, setup.data, true, 8, exp2)
      _Assert.test_match(h, rule, src3, 0, setup.data, true, 7, exp3)
      _Assert.test_match(h, rule, src4, 0, setup.data, true, 3, exp4)
    ])

class iso _TestParserLiteralChar is UnitTest
  fun name(): String => "parser/literal/Char"
  fun exclusion_group(): String => "parser/literal"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.literal_char()

    let src1 = setup.src("'A'")
    let loc1 = parser.Loc(src1)
    let inf1 = ast.SrcInfo(setup.data.locator(), loc1, loc1 + 3)
    let exp1 = ast.LiteralChar.from(inf1, 'A')

    let src2 = setup.src("'\\n'")
    let loc2 = parser.Loc(src2)
    let inf2 = ast.SrcInfo(setup.data.locator(), loc2, loc2 + 4)
    let exp2 = ast.LiteralChar.from(inf2, '\n')

    let src3 = setup.src("'\\x41'")
    let loc3 = parser.Loc(src3)
    let inf3 = ast.SrcInfo(setup.data.locator(), loc3, loc3 + 6)
    let exp3 = ast.LiteralChar.from(inf3, 65)

    let src4 = setup.src("'ABCD'")
    let loc4 = parser.Loc(src4)
    let inf4 = ast.SrcInfo(setup.data.locator(), loc4, loc4 + 6)
    let exp4 = ast.LiteralChar.from(inf4, 0x41424344)

    let src5 = setup.src("''")
    let loc5 = parser.Loc(src5)
    let inf5 = ast.SrcInfo(setup.data.locator(), loc5, loc5 + 2)

    _Assert.test_all(h, [
      _Assert.test_match(h, rule, src1, 0, setup.data, true, 3, exp1)
      _Assert.test_match(h, rule, src1, 1, setup.data, false)
      _Assert.test_match(h, rule, src2, 0, setup.data, true, 4, exp2)
      _Assert.test_match(h, rule, src2, 1, setup.data, false)
      _Assert.test_match(h, rule, src3, 0, setup.data, true, 6, exp3)
      _Assert.test_match(h, rule, src4, 0, setup.data, true, 6, exp4)
      _Assert.test_match(h, rule, src5, 0, setup.data, false, 0, None,
        ErrorMsg.literal_char_empty())
    ])

class iso _TestParserLiteralStringRegular is UnitTest
  fun name(): String => "parser/literal/String/regular"
  fun exclusion_group(): String => "parser/literal"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.literal_string()

    let str1 = "one, two, \" three \0x2f"
    let src1 = setup.src("\"one, two, \\\" three \\0x2f\"")
    let len1 = USize(26)
    let loc1 = parser.Loc(src1)
    let inf1 = ast.SrcInfo(setup.data.locator(), loc1, loc1 + len1)
    let exp1 = ast.LiteralString.from(setup.context, false, inf1, str1)

    _Assert.test_all(h, [
      _Assert.test_match(h, rule, src1, 0, setup.data, true, len1, exp1)
    ])

class iso _TestParserLiteralStringTriple is UnitTest
  fun name(): String => "parser/literal/String/triple"
  fun exclusion_group(): String => "parser/literal"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.literal_string()

    let str1 = "one\ntwo\nthree"
    let src1 = setup.src("\"\"\"  \n   one\n   two\n   three\n\"\"\"")
    let len1 = USize(32)
    let loc1 = parser.Loc(src1)
    let inf1 = ast.SrcInfo(setup.data.locator(), loc1, loc1 + len1)
    let exp1 = ast.LiteralString.from(setup.context, true, inf1, str1)

    _Assert.test_all(h, [
      _Assert.test_match(h, rule, src1, 0, setup.data, true, len1, exp1)
    ])
