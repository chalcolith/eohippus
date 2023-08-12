use "collections/persistent"
use "pony_test"

use ast = "../ast"
use json = "../json"
use parser = "../parser"
use ".."

primitive _TestParserLiteral
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
    let rule = setup.builder.literal.bool()

    let expected_true =
      """
        {
          "name": "LiteralBool",
          "value": true
        }
      """

    let expected_false =
      """
        {
          "name": "LiteralBool",
          "value": false
        }
      """

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, "true", expected_true)
        _Assert.test_match(h, rule, setup.data, "false", expected_false)
        _Assert.test_match(h, rule, setup.data, "", None)
        _Assert.test_match(h, rule, setup.data, "foo", None)
        _Assert.test_match(h, rule, setup.data, " ", None) ])

class iso _TestParserLiteralIntegerDec is UnitTest
  fun name(): String => "parser/literal/Integer/Decimal"
  fun exclusion_group(): String => "parser/literal"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.literal.integer()

    let expected =
      """
        {
          "name": "LiteralInteger",
          "kind": "DecimalInteger",
          "value": 1234
        }
      """

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, "1234", expected)
        _Assert.test_match(h, rule, setup.data, "1234 ", expected)
        _Assert.test_match(h, rule, setup.data, "1_2_3_4", expected)
        _Assert.test_match(h, rule, setup.data, "_1234", None)
        _Assert.test_match(h, rule, setup.data, "", None)
        _Assert.test_match(h, rule, setup.data, " ", None)
      ])

class iso _TestParserLiteralIntegerHex is UnitTest
  fun name(): String => "parser/literal/Integer/Hexadecimal"
  fun exclusion_group(): String => "parser/literal"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.literal.integer()

    let expected =
      """
        {
          "name": "LiteralInteger",
          "kind": "HexadecimalInteger",
          "value": 1194684
        }
      """

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, "0x12_3abc", expected) ])

class iso _TestParserLiteralIntegerBin is UnitTest
  fun name(): String => "parser/literal/Integer/Binary"
  fun exclusion_group(): String => "parser/literal"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.literal.integer()

    let expected =
      """
        {
          "name": "LiteralInteger",
          "kind": "BinaryInteger",
          "value": 2421
        }
      """

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, "0b100101110101", expected) ])

class iso _TestParserLiteralFloat is UnitTest
  fun name(): String => "parser/literal/Float"
  fun exclusion_group(): String => "parser/literal"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.literal.float()

    let expected_1 =
      """
        {
          "name": "LiteralFloat",
          "value": 1.23456e-40
        }
      """
    let expected_2 =
      """
        {
          "name": "LiteralFloat",
          "value": 2.345e+63
        }
      """
    let expected_3 =
      """
        {
          "name": "LiteralFloat",
          "value": 345.678
        }
      """
    let expected_4 =
      """
        {
          "name": "LiteralFloat",
          "value": 456
        }
      """

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, "123.456e-42", expected_1)
        _Assert.test_match(h, rule, setup.data, "23.45e62", expected_2)
        _Assert.test_match(h, rule, setup.data, "23.45e62 ", expected_2)
        _Assert.test_match(h, rule, setup.data, "345.678", expected_3)
        _Assert.test_match(h, rule, setup.data, "456", expected_4)
        _Assert.test_match(h, rule, setup.data, "", None) ])

class iso _TestParserLiteralChar is UnitTest
  fun name(): String => "parser/literal/Char"
  fun exclusion_group(): String => "parser/literal"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.literal.char()
    h.fail()

    let expected_1 =
      """
        {
          "name": "LiteralChar",
          "kind": "CharLiteral",
          "value": "A"
        }
      """

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, "'A'", expected_1) ])

    // let src1 = setup.src("'A'")
    // let loc1 = parser.Loc(src1)
    // let inf1 = ast.SrcInfo(setup.data.locator(), loc1, loc1 + 3)
    // let exp1 = ast.LiteralChar.from(inf1, 'A')

    // let src2 = setup.src("'\\n'")
    // let loc2 = parser.Loc(src2)
    // let inf2 = ast.SrcInfo(setup.data.locator(), loc2, loc2 + 4)
    // let exp2 = ast.LiteralChar.from(inf2, '\n')

    // let src3 = setup.src("'\\x41'")
    // let loc3 = parser.Loc(src3)
    // let inf3 = ast.SrcInfo(setup.data.locator(), loc3, loc3 + 6)
    // let exp3 = ast.LiteralChar.from(inf3, 65)

    // let src4 = setup.src("'ABCD'")
    // let loc4 = parser.Loc(src4)
    // let inf4 = ast.SrcInfo(setup.data.locator(), loc4, loc4 + 6)
    // let exp4 = ast.LiteralChar.from(inf4, 0x41424344)

    // let src5 = setup.src("''")
    // let loc5 = parser.Loc(src5)
    // let inf5 = ast.SrcInfo(setup.data.locator(), loc5, loc5 + 2)

    // _Assert.test_all(h, [
    //   _Assert.test_match(h, rule, src1, 0, setup.data, true, 3, exp1)
    //   _Assert.test_match(h, rule, src1, 1, setup.data, false)
    //   _Assert.test_match(h, rule, src2, 0, setup.data, true, 4, exp2)
    //   _Assert.test_match(h, rule, src2, 1, setup.data, false)
    //   _Assert.test_match(h, rule, src3, 0, setup.data, true, 6, exp3)
    //   _Assert.test_match(h, rule, src4, 0, setup.data, true, 6, exp4)
    //   _Assert.test_match(h, rule, src5, 0, setup.data, false, 0, None,
    //     ErrorMsg.literal_char_empty())
    // ])

class iso _TestParserLiteralStringRegular is UnitTest
  fun name(): String => "parser/literal/String/regular"
  fun exclusion_group(): String => "parser/literal"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.literal.string()
    h.fail()

    // let str1 = "one, two, \" three \0x2f"
    // let src1 = setup.src("\"one, two, \\\" three \\0x2f\"")
    // let len1 = USize(26)
    // let loc1 = parser.Loc(src1)
    // let inf1 = ast.SrcInfo(setup.data.locator(), loc1, loc1 + len1)
    // let exp1 = ast.LiteralString.from(setup.context, false, inf1, str1)

    // _Assert.test_all(h, [
    //   _Assert.test_match(h, rule, src1, 0, setup.data, true, len1, exp1)
    // ])

class iso _TestParserLiteralStringTriple is UnitTest
  fun name(): String => "parser/literal/String/triple"
  fun exclusion_group(): String => "parser/literal"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.literal.string()
    h.fail()

    // let str1 = "one\ntwo\nthree"
    // let src1 = setup.src("\"\"\"  \n   one\n   two\n   three\n\"\"\"")
    // let len1 = USize(32)
    // let loc1 = parser.Loc(src1)
    // let inf1 = ast.SrcInfo(setup.data.locator(), loc1, loc1 + len1)
    // let exp1 = ast.LiteralString.from(setup.context, true, inf1, str1)

    // _Assert.test_all(h, [
    //   _Assert.test_match(h, rule, src1, 0, setup.data, true, len1, exp1)
    // ])
