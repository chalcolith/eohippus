use "pony_test"

use ast = "../ast"
use json = "../json"
use parser = "../parser"
use ".."

primitive _TestParserTypedef
  fun apply(test: PonyTest) =>
    test(_TestParserTypedefField)
    test(_TestParserTypedefMethod)
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

class iso _TestParserTypedefMethod is UnitTest
  fun name(): String => "parser/typedef/Method"
  fun exclusion_group(): String => "parser/typedef"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.typedef.method

    //            0     5     10   15   20   25   30   35    40    45   50
    let source = "fun \\ann\\ ref name[A](p: B): USize ? \"doc\" => 1 + 2"
    let expected = """
      {
        "name": "TypedefMethod",
        "kind": {
          "name": "Keyword",
          "string": "fun"
        },
        "cap": {
          "name": "Keyword",
          "string": "ref"
        },
        "identifier": {
          "name": "Identifier",
          "string": "name"
        },
        "type_params": {
          "name": "TypeParams",
          "params": [
            {
              "name": "TypeParam",
              "constraint": {
                "name": "TypeNominal",
                "rhs": { "name": "Identifier", "string": "A" }
              }
            }
          ]
        },
        "params": {
          "name": "MethodParams",
          "params": [
            {
              "name": "MethodParam",
              "identifier": { "name": "Identifier", "string": "p" },
              "constraint": {
                "name": "TypeNominal",
                "rhs": { "name": "Identifier", "string": "B" }
              }
            }
          ]
        },
        "return_type": {
          "name": "TypeNominal",
          "rhs": { "name": "Identifier", "string": "USize" }
        },
        "partial": true,
        "body": {
          "name": "ExpOperation",
          "op": { "name": "Token", "string": "+" },
          "lhs": {
            "name": "ExpAtom",
            "body": { "name": "LiteralInteger", "value": 1 }
          },
          "rhs": {
            "name": "ExpAtom",
            "body": { "name": "LiteralInteger", "value": 2 }
          }
        },
        "annotation": {
          "name": "Annotation",
          "identifiers": [
            { "name": "Identifier", "string": "ann" }
          ]
        },
        "doc_strings": [
          {
            "name": "DocString",
            "string": { "name": "LiteralString", "value": "doc" }
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
