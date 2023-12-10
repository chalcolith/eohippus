use "pony_test"

use ast = "../ast"
use json = "../json"
use parser = "../parser"
use ".."

primitive _TestParserTypedef
  fun apply(test: PonyTest) =>
    test(_TestParserTypedefField)
    test(_TestParserTypedefPrimitiveSimple)

class iso _TestParserTypedefField is UnitTest
  fun name(): String => "parser/typedef/Field"
  fun exclusion_group(): String => "parser/typedef"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.typedef.field

    let source = "let foo: USize = 123 \"\"\"doc\"\"\""
    let expected = """
      {
        "name": "TypedefField",
        "kind": {
          "name": "Keyword",
          "string": "let"
        },
        "identifier": {
          "name": "Identifier",
          "string": "foo"
        },
        "type": {
          "name": "TypeNominal",
          "rhs": {
            "name": "Identifier",
            "string": "USize"
          }
        },
        "value": {
          "name": "ExpAtom",
          "body": {
            "name": "LiteralInteger",
            "kind": "DecimalInteger",
            "value": 123
          }
        },
        "doc_strings": [
          {
            "name": "DocString",
            "string": {
              "name": "LiteralString",
              "kind": "StringTripleQuote",
              "value": "doc"
            }
          }
        ]
      }
    """

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])


class iso _TestParserTypedefPrimitiveSimple is UnitTest
  fun name(): String => "parser/typedef/Primitive/simple"
  fun exclusion_group(): String => "parser/typedef"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.typedef.typedef_primitive

    let source = "primitive FooBar\n\"\"\"docs\"\"\"  "
    let expected =
      """
        {
          "name": "TypedefPrimitive",
          "identifier": {
            "name": "Identifier",
            "string": "FooBar",
            "post_trivia": [
              {
                "name": "Trivia",
                "kind": "EndOfLineTrivia"
              }
            ]
          },
          "doc_strings": [
            {
              "name": "DocString",
              "string": {
                "name": "LiteralString",
                "kind": "StringTripleQuote",
                "value": "docs",
                "post_trivia": [
                  {
                    "name": "Trivia",
                    "kind": "WhiteSpaceTrivia"
                  }
                ]
              }
            }
          ]
        }
      """

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])
