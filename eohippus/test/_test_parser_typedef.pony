use "pony_test"

use ast = "../ast"
use json = "../json"
use parser = "../parser"
use ".."

primitive _TestParserTypedef
  fun apply(test: PonyTest) =>
    test(_TestParserTypedefField)
    test(_TestParserTypedefMethod)
    test(_TestParserTypedefMembers)
    test(_TestParserTypedefPrimitive)
    test(_TestParserTypedefAlias)
    test(_TestParserTypedefClass)

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

class iso _TestParserTypedefMembers is UnitTest
  fun name(): String => "parser/typedef/Members"
  fun exclusion_group(): String => "parser/typedef"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.typedef.members

    let source = """
      let a: USize
      fun b() => None
    """

    let expected = """
      {
        "name": "TypedefMembers",
        "fields": [
          {
            "name": "TypedefField",
            "kind": { "name": "Keyword", "string": "let" },
            "identifier": { "name": "Identifier", "string": "a" },
            "type": {
              "name": "TypeNominal",
              "rhs": { "name": "Identifier", "string": "USize" }
            }
          }
        ],
        "methods": [
          {
            "name": "TypedefMethod",
            "kind": { "name": "Keyword", "string": "fun" },
            "identifier": { "name": "Identifier", "string": "b" },
            "body": {
              "name": "ExpAtom",
              "body": { "name": "Identifier", "string": "None" }
            }
          }
        ]
      }
    """

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])

class iso _TestParserTypedefPrimitive is UnitTest
  fun name(): String => "parser/typedef/Primitive"
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

class iso _TestParserTypedefAlias is UnitTest
  fun name(): String => "parser/typedef/Alias"
  fun exclusion_group(): String => "parser/typedef"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.typedef.typedef_alias

    let source = "type A[T] is (B | (C & D))"
    let expected = """
      {
        "name": "TypedefAlias",
        "identifier": { "name": "Identifier", "string": "A" },
        "type_params": {
          "name": "TypeParams",
          "params": [
            {
              "name": "TypeParam",
              "constraint": {
                "name": "TypeNominal",
                "rhs": { "name": "Identifier", "string": "T" }
              }
            }
          ]
        },
        "type": {
          "name": "TypeInfix",
          "op": { "name": "Token", "string": "|" },
          "types": [
            {
              "name": "TypeNominal",
              "rhs": { "name": "Identifier", "string": "B" }
            },
            {
              "name": "TypeInfix",
              "op": { "name": "Token", "string": "&" },
              "types": [
                {
                  "name": "TypeNominal",
                  "rhs": { "name": "Identifier", "string": "C" }
                },
                {
                  "name": "TypeNominal",
                  "rhs": { "name": "Identifier", "string": "D" }
                }
              ]
            }
          ]
        }
      }
    """

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])

class iso _TestParserTypedefClass is UnitTest
  fun name(): String => "parser/typedef/Class"
  fun exclusion_group(): String => "parser/typedef"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.typedef.typedef_class

    let source = """
      actor \a\ val Foo[A]
        let bar: U8
        new create(qux: U8) => qux + 123
    """
    let expected = """
      {
        "name": "TypedefClass",
        "kind": { "name": "Keyword", "string": "actor" },
        "annotation": {
          "name": "Annotation",
          "identifiers": [
            { "name": "Identifier", "string": "a" }
          ]
        },
        "cap": { "name": "Keyword", "string": "val" },
        "identifier": { "name": "Identifier", "string": "Foo" },
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
        "members": {
          "name": "TypedefMembers",
          "fields": [
            {
              "name": "TypedefField",
              "kind": { "name": "Keyword", "string": "let" },
              "identifier": { "name": "Identifier", "string": "bar" },
              "type": {
                "name": "TypeNominal",
                "rhs": { "name": "Identifier", "string": "U8" }
              }
            }
          ],
          "methods": [
            {
              "name": "TypedefMethod",
              "kind": { "name": "Keyword", "string": "new" },
              "identifier": { "name": "Identifier", "string": "create" },
              "params": {
                "name": "MethodParams",
                "params": [
                  {
                    "name": "MethodParam",
                    "identifier": { "name": "Identifier", "string": "qux" },
                    "constraint": {
                      "name": "TypeNominal",
                      "rhs": { "name": "Identifier", "string": "U8" }
                    }
                  }
                ]
              },
              "body": {
                "name": "ExpOperation",
                "op": { "name": "Token", "string": "+" },
                "lhs": {
                  "name": "ExpAtom",
                  "body": { "name": "Identifier", "string": "qux" }
                },
                "rhs": {
                  "name": "ExpAtom",
                  "body": {
                    "name": "LiteralInteger",
                    "value": 123
                  }
                }
              }
            }
          ]
        }
      }
    """

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])
