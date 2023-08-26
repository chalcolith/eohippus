use "pony_test"

use ast = "../ast"
use json = "../json"
use parser = "../parser"
use ".."

primitive _TestParserExpression
  fun apply(test: PonyTest) =>
    test(_TestParserExpressionIdentifier)
    test(_TestParserExpressionItem)
    test(_TestParserExpressionIf)
    test(_TestParserExpressionIfDef)
    test(_TestParserExpressionSequence)

class iso _TestParserExpressionIdentifier is UnitTest
  fun name(): String => "parser/expression/Identifier"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.token.identifier()

    let expected = """ { "name": "Identifier", "string": "a1_'" } """

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, "a1_'", expected)
        _Assert.test_match(h, rule, setup.data, "1abc", None)
        _Assert.test_match(h, rule, setup.data, "", None) ])

class iso _TestParserExpressionItem is UnitTest
  fun name(): String => "parser/expression/Item"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item()

    let expected_id = """ { "name":"Identifier", "string": "foo" } """

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, "foo", expected_id) ])

class iso _TestParserExpressionSequence is UnitTest
  fun name(): String => "parser/expression/Sequence"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.seq()

    let expected1 =
      """
        {
          "name": "ExpSequence",
          "expressions": [
            {
              "name": "Identifier",
              "string": "foo"
            },
            {
              "name": "LiteralInteger",
              "kind": "DecimalInteger",
              "value": 1
            },
            {
              "name": "LiteralBool",
              "value": true
            }
          ]
        }
      """

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, "foo; 1; true", expected1)])

class iso _TestParserExpressionIf is UnitTest
  fun name(): String => "parser/expression/If"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item()

    let source = "if true then foo elseif false then bar else baz end"
    let expected =
      """
        {
          "name": "ExpIf",
          "kind": "IfExp",
          "conditions": [
            {
              "if_true": {
                "name": "ExpSequence",
                "expressions": [
                  { "name": "LiteralBool", "value": true }
                ]
              },
              "then_block": {
                "name": "ExpSequence",
                "expressions": [
                  { "name": "Identifier", "string": "foo" }
                ]
              }
            },
            {
              "if_true": {
                "name": "ExpSequence",
                "expressions": [
                  { "name": "LiteralBool", "value": false }
                ]
              },
              "then_block": {
                "name": "ExpSequence",
                "expressions": [
                  { "name": "Identifier", "string": "bar" }
                ]
              }
            }
          ],
          "else_block": {
            "name": "ExpSequence",
            "expressions": [
              { "name": "Identifier", "string": "baz" }
            ]
          }
        }
      """

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])

class iso _TestParserExpressionIfDef is UnitTest
  fun name(): String => "parser/expression/IfDef"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item()

    let source = "ifdef windows then foo elseif unix then bar else baz end"
    let expected =
      """
        {
          "name": "ExpIf",
          "kind": "IfDef",
          "conditions": [
            {
              "if_true": {
                "name": "ExpSequence",
                "expressions": [
                  { "name": "Identifier", "string": "windows" }
                ]
              },
              "then_block": {
                "name": "ExpSequence",
                "expressions": [
                  { "name": "Identifier", "string": "foo" }
                ]
              }
            },
            {
              "if_true": {
                "name": "ExpSequence",
                "expressions": [
                  { "name": "Identifier", "string": "unix" }
                ]
              },
              "then_block": {
                "name": "ExpSequence",
                "expressions": [
                  { "name": "Identifier", "string": "bar" }
                ]
              }
            }
          ],
          "else_block": {
            "name": "ExpSequence",
            "expressions": [
              { "name": "Identifier", "string": "baz" }
            ]
          }
        }
      """

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])
