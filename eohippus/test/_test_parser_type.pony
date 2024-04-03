use "pony_test"

use ast = "../ast"
use json = "../json"
use parser = "../parser"
use ".."

primitive _TestParserType
  fun apply(test: PonyTest) =>
    test(_TestParserTypeArrow)
    test(_TestParserTypeAtom)
    test(_TestParserTypeInfix)
    test(_TestParserTypeNominal)
    test(_TestParserTypeLambda)

class iso _TestParserTypeArrow is UnitTest
  fun name(): String => "parser/type/Arrow"
  fun exclusion_group(): String => "parser/type"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.type_type.arrow

    let src = "this->N"
    let exp =
      """
        {
          "name": "TypeArrow",
          "lhs": 0,
          "rhs": 2,
          "children": [
            {
              "name": "TypeAtom",
              "body": 0,
              "children": [
                {
                  "name": "Keyword",
                  "string": "this"
                }
              ]
            },
            {
              "name": "Token",
              "string": "->"
            },
            {
              "name": "TypeNominal",
              "rhs": 0,
              "children": [
                {
                  "name": "Identifier",
                  "string": "N"
                }
              ]
            }
          ]
        }
      """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])

class iso _TestParserTypeAtom is UnitTest
  fun name(): String => "parser/type/Atom"
  fun exclusion_group(): String => "parser/type"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.type_type.atom

    let source1 = "this"
    let expected1 =
      """
        {
          "name": "TypeAtom",
          "body": 0,
          "children": [
            { "name": "Keyword", "string": "this" }
          ]
        }
      """

    let source2 = "trn"
    let expected2 =
      """
        {
          "name": "TypeAtom",
          "body": 0,
          "children": [
            { "name": "Keyword", "string": "trn" }
          ]
        }
      """

    let source3 = "(a, b)"
    let expected3 =
      """
        {
          "name": "TypeTuple",
          "types": [
            1,
            3
          ],
          "children": [
            {
              "name": "Token",
              "string": "("
            },
            {
              "name": "TypeNominal",
              "rhs": 0,
              "children": [
                {
                  "name": "Identifier",
                  "string": "a"
                }
              ]
            },
            {
              "name": "Token",
              "string": ","
            },
            {
              "name": "TypeNominal",
              "rhs": 0,
              "children": [
                {
                  "name": "Identifier",
                  "string": "b"
                }
              ]
            },
            {
              "name": "Token",
              "string": ")"
            }
          ]
        }
      """

    _Assert.test_all(h,
      [ _Assert.test_match(h, rule, setup.data, source1, expected1)
        _Assert.test_match(h, rule, setup.data, source2, expected2)
        _Assert.test_match(h, rule, setup.data, source3, expected3) ])

class iso _TestParserTypeInfix is UnitTest
  fun name(): String => "parser/type/Infix"
  fun exclusion_group(): String => "parser/type"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.type_type.atom

    let src = "(a & (b | c))"
    let exp =
      """
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
                  "string": "a"
                }
              ]
            },
            {
              "name": "Token",
              "string": "&"
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
                      "string": "b"
                    }
                  ]
                },
                {
                  "name": "Token",
                  "string": "|"
                },
                {
                  "name": "TypeNominal",
                  "rhs": 0,
                  "children": [
                    {
                      "name": "Identifier",
                      "string": "c"
                    }
                  ]
                }
              ]
            }
          ]
        }
      """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])

class iso _TestParserTypeNominal is UnitTest
  fun name(): String => "parser/type/Nominal"
  fun exclusion_group(): String => "parser/type"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.type_type.nominal

    let src = "p.t[N] iso^"
    let exp =
      """
        {
          "name": "TypeNominal",
          "lhs": 0,
          "rhs": 2,
          "params": 3,
          "cap": 4,
          "eph": 5,
          "children": [
            {
              "name": "Identifier",
              "string": "p"
            },
            {
              "name": "Token",
              "string": "."
            },
            {
              "name": "Identifier",
              "string": "t"
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
                          "string": "N"
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
              "string": "iso"
            },
            {
              "name": "Token",
              "string": "^"
            }
          ]
        }
      """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])

class iso _TestParserTypeLambda is UnitTest
  fun name(): String => "parser/type/Lambda"
  fun exclusion_group(): String => "parser/type"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.type_type.arrow

    let src = "@{ref foo[A,B](USize,Bool):F32?} trn!"
    let exp =
      """
        {
          "name": "TypeLambda",
          "bare": true,
          "partial": true,
          "cap": 2,
          "identifier": 3,
          "type_params": 4,
          "param_types": [
            6,
            8
          ],
          "return_type": 11,
          "rcap": 14,
          "reph": 15,
          "children": [
            {
              "name": "Token",
              "string": "@"
            },
            {
              "name": "Token",
              "string": "{"
            },
            {
              "name": "Keyword",
              "string": "ref"
            },
            {
              "name": "Identifier",
              "string": "foo"
            },
            {
              "name": "TypeParams",
              "params": [
                1,
                3
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
                          "string": "A"
                        }
                      ]
                    }
                  ]
                },
                {
                  "name": "Token",
                  "string": ","
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
                          "string": "B"
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
              "name": "Token",
              "string": "("
            },
            {
              "name": "TypeNominal",
              "rhs": 0,
              "children": [
                {
                  "name": "Identifier",
                  "string": "USize"
                }
              ]
            },
            {
              "name": "Token",
              "string": ","
            },
            {
              "name": "TypeNominal",
              "rhs": 0,
              "children": [
                {
                  "name": "Identifier",
                  "string": "Bool"
                }
              ]
            },
            {
              "name": "Token",
              "string": ")"
            },
            {
              "name": "Token",
              "string": ":"
            },
            {
              "name": "TypeNominal",
              "rhs": 0,
              "children": [
                {
                  "name": "Identifier",
                  "string": "F32"
                }
              ]
            },
            {
              "name": "Token",
              "string": "?"
            },
            {
              "name": "Token",
              "string": "}"
            },
            {
              "name": "Keyword",
              "string": "trn"
            },
            {
              "name": "Token",
              "string": "!"
            }
          ]
        }
      """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])
