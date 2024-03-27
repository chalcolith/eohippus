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

    let src = "primitive FooBar\n\"\"\"docs\"\"\"  "
    let exp =
      """
        {
          "name": "TypedefPrimitive",
          "identifier": 1,
          "children": [
            {
              "name": "Keyword",
              "string": "primitive"
            },
            {
              "name": "Identifier",
              "string": "FooBar"
            },
            {
              "name": "DocString",
              "string": 0,
              "children": [
                {
                  "name": "LiteralString",
                  "kind": "StringTripleQuote",
                  "value": "docs"
                }
              ]
            }
          ]
        }
      """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])

class iso _TestParserTypedefAlias is UnitTest
  fun name(): String => "parser/typedef/Alias"
  fun exclusion_group(): String => "parser/typedef"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.typedef.typedef_alias

    let src = "type A[T] is (B | (C & D))"
    let exp = """
      {
        "name": "TypedefAlias",
        "identifier": 1,
        "type_params": 2,
        "type": 4,
        "children": [
          {
            "name": "Keyword",
            "string": "type"
          },
          {
            "name": "Identifier",
            "string": "A"
          },
          {
            "name": "TypeParams",
            "params": [
              1
            ],
            "children": [
              {
                "name": "Token",
                "string": "["
              },
              {
                "name": "TypeParam",
                "constraint": 0,
                "children": [
                  {
                    "name": "TypeNominal",
                    "rhs": 0,
                    "children": [
                      {
                        "name": "Identifier",
                        "string": "T"
                      }
                    ]
                  }
                ]
              },
              {
                "name": "Token",
                "string": "]"
              }
            ]
          },
          {
            "name": "Keyword",
            "string": "is"
          },
          {
            "name": "TypeInfix",
            "op": 1,
            "types": [
              0,
              2
            ],
            "children": [
              {
                "name": "TypeNominal",
                "rhs": 0,
                "children": [
                  {
                    "name": "Identifier",
                    "string": "B"
                  }
                ]
              },
              {
                "name": "Token",
                "string": "|"
              },
              {
                "name": "TypeInfix",
                "op": 1,
                "types": [
                  0,
                  2
                ],
                "children": [
                  {
                    "name": "TypeNominal",
                    "rhs": 0,
                    "children": [
                      {
                        "name": "Identifier",
                        "string": "C"
                      }
                    ]
                  },
                  {
                    "name": "Token",
                    "string": "&"
                  },
                  {
                    "name": "TypeNominal",
                    "rhs": 0,
                    "children": [
                      {
                        "name": "Identifier",
                        "string": "D"
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }
    """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])

class iso _TestParserTypedefClass is UnitTest
  fun name(): String => "parser/typedef/Class"
  fun exclusion_group(): String => "parser/typedef"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.typedef.typedef_class

    let src = """
      actor \a\ val Foo[A]
        let bar: U8
        new create(qux: U8) => qux + 123
    """
    let exp = """
      {
        "name": "TypedefClass",
        "kind": 0,
        "annotation": 1,
        "cap": 2,
        "identifier": 3,
        "type_params": 4,
        "members": 5,
        "children": [
          { "name": "Keyword", "string": "actor" },
          {
            "name": "Annotation",
            "identifiers": [ 1 ],
            "children": [
              { "name": "Token" },
              { "name": "Identifier", "string": "a" },
              { "name": "Token" }
            ]
          },
          { "name": "Keyword", "string": "val" },
          { "name": "Identifier", "string": "Foo" },
          {
            "name": "TypeParams",
            "params": [ 1 ],
            "children": [
              { "name": "Token", "string": "[" },
              {
                "name": "TypeParam",
                "constraint": 0,
                "children": [
                  {
                    "name": "TypeNominal",
                    "rhs": 0,
                    "children": [
                      { "name": "Identifier", "string": "A" }
                    ]
                  }
                ]
              },
              { "name": "Token", "string": "]" }
            ]
          },
          {
            "name": "TypedefMembers",
            "fields": [ 0 ],
            "methods": [ 1 ],
            "children": [
              {
                "name": "TypedefField",
                "kind": 0,
                "identifier": 1,
                "type": 3,
                "children": [
                  { "name": "Keyword", "string": "let" },
                  { "name": "Identifier", "string": "bar" },
                  { "name": "Token", "string": ":" },
                  {
                    "name": "TypeNominal",
                    "rhs": 0,
                    "children": [
                      { "name": "Identifier", "string": "U8" }
                    ]
                  }
                ]
              },
              {
                "name": "TypedefMethod",
                "kind": 0,
                "identifier": 1,
                "params": 3,
                "body": 6,
                "children": [
                  { "name": "Keyword", "string": "new" },
                  { "name": "Identifier", "string": "create" },
                  { "name": "Token", "string": "(" },
                  {
                    "name": "MethodParams",
                    "params": [ 0 ],
                    "children": [
                      {
                        "name": "MethodParam",
                        "identifier": 0,
                        "constraint": 2,
                        "children": [
                          { "name": "Identifier", "string": "qux" },
                          { "name": "Token", "string": ":" },
                          {
                            "name": "TypeNominal",
                            "rhs": 0,
                            "children": [
                              { "name": "Identifier", "string": "U8" }
                            ]
                          }
                        ]
                      }
                    ]
                  },
                  { "name": "Token", "string": ")" },
                  { "name": "Token", "string": "=>" },
                  {
                    "name": "ExpOperation",
                    "lhs": 0,
                    "op": 1,
                    "rhs": 2,
                    "children": [
                      {
                        "name": "ExpAtom",
                        "body": 0,
                        "children": [
                          { "name": "Identifier", "string": "qux" },
                        ]
                      },
                      { "name": "Token", "string": "+" },
                      {
                        "name": "ExpAtom",
                        "body": 0,
                        "children": [
                          {
                            "name": "LiteralInteger",
                            "kind": "DecimalInteger",
                            "value": 123
                          }
                        ]
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }
    """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])
