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
    let rule = setup.builder.literal.bool

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
    let rule = setup.builder.literal.integer

    let expected =
      """
        {
          "name": "LiteralInteger",
          "kind": "DecimalInteger",
          "value": 1234
        }
      """

    let expected_t =
      """
        {
          "name": "LiteralInteger",
          "kind": "DecimalInteger",
          "value": 1234,
          "post_trivia": [
            {
              "name": "Trivia",
              "kind": "WhiteSpaceTrivia"
            }
          ]
        }
      """

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, "1234", expected)
        _Assert.test_match(h, rule, setup.data, "1234 ", expected_t)
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
    let rule = setup.builder.literal.integer

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
    let rule = setup.builder.literal.integer

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
    let rule = setup.builder.literal.float

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
          "value": 2.345e+64
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
          "name": "LiteralInteger",
          "kind": "DecimalInteger",
          "value": 456
        }
      """

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, "123.456e-42", expected_1)
        _Assert.test_match(h, rule, setup.data, "23.45e63", expected_2)
        _Assert.test_match(h, rule, setup.data, "23.45e63 ", expected_2)
        _Assert.test_match(h, rule, setup.data, "345.678", expected_3)
        _Assert.test_match(h, rule, setup.data, "456", expected_4)
        _Assert.test_match(h, rule, setup.data, "", None)
      ])

class iso _TestParserLiteralChar is UnitTest
  fun name(): String => "parser/literal/Char"
  fun exclusion_group(): String => "parser/literal"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.literal.char

    let expected_1 =
      """
        {
          "name": "LiteralChar",
          "kind": "CharLiteral",
          "value": "A"
        }
      """

    let expected_2 =
      """
        {
          "name": "LiteralChar",
          "kind": "CharEscaped",
          "value": "\n"
        }
      """

    let expected_3 =
      """
        {
          "name": "LiteralChar",
          "kind": "CharEscaped",
          "value": "A"
        }
      """

    let expected_4 =
      """
        {
          "name": "LiteralChar",
          "kind": "CharLiteral",
          "value": "\uFFFD"
        }
      """

    let expected_5 =
      """
        {
          "name": "LiteralChar",
          "kind": "CharUnicode",
          "value": "\uFFFD"
        }
      """

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, "'A'", expected_1)
        _Assert.test_match(h, rule, setup.data, "'\\n'", expected_2)
        _Assert.test_match(h, rule, setup.data, "'\\x41'", expected_3)
        _Assert.test_match(h, rule, setup.data, "'ABCD'", expected_4)
        _Assert.test_match(h, rule, setup.data, "'\\uFFFD'", expected_5)
        _Assert.test_match(h, rule, setup.data, "''", None)
        _Assert.test_match(h, rule, setup.data, " ", None)
      ])

class iso _TestParserLiteralStringRegular is UnitTest
  fun name(): String => "parser/literal/String/regular"
  fun exclusion_group(): String => "parser/literal"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.literal.string

    let expected_1 =
      """
        {
          "name": "LiteralString",
          "kind": "StringLiteral",
          "value": "hello"
        }
      """

    let expected_2 =
      """
        {
          "name": "LiteralString",
          "kind": "StringLiteral",
          "value": "one, two, \" three /"
        }
      """

    let expected_3 =
      """
        {
          "name": "LiteralString",
          "kind": "StringLiteral",
          "value": "a\"/"
        }
      """

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, "\"hello\"", expected_1)
        _Assert.test_match(
          h, rule, setup.data, "\"one, two, \\\" three \\x2f\"", expected_2)
        _Assert.test_match(h, rule, setup.data, "\"a\\\"\\x2f\"", expected_3)
      ])

class iso _TestParserLiteralStringTriple is UnitTest
  fun name(): String => "parser/literal/String/triple"
  fun exclusion_group(): String => "parser/literal"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.literal.string

    let expected =
      """
        {
          "name": "LiteralString",
          "kind": "StringTripleQuote",
          "value": "one\ntwo\nthree",
          "post_trivia": [
            {
              "name": "Trivia",
              "kind": "WhiteSpaceTrivia"
            }
          ]
        }
      """

    let source = "\"\"\"  \n   one\n   two\n   three\n\"\"\" "

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])
