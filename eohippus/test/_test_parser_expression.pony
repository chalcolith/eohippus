use "pony_test"

use ast = "../ast"
use json = "../json"
use parser = "../parser"
use ".."

primitive _TestParserExpression
  fun apply(test: PonyTest) =>
    test(_TestParserExpressionIdentifier)
    test(_TestParserExpressionItem)
    test(_TestParserExpressionAssignment)
    test(_TestParserExpressionIf)
    test(_TestParserExpressionIfDef)
    test(_TestParserExpressionSequence)
    test(_TestParserExpressionJump)
    test(_TestParserExpressionInfix)
    test(_TestParserExpressionPrefix)
    test(_TestParserExpressionPostfix)
    test(_TestParserExpressionTuple)
    test(_TestParserExpressionParens)
    test(_TestParserExpressionRecover)
    test(_TestParserExpressionTry)
    test(_TestParserExpressionArray)
    test(_TestParserExpressionConsume)
    test(_TestParserExpressionWhile)
    test(_TestParserExpressionRepeat)
    test(_TestParserExpressionFor)
    test(_TestParserExpressionMatch)
    test(_TestParserExpressionDecl)
    test(_TestParserExpressionWith)

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

    let expected_id =
      """
        {
          "name": "ExpAtom",
          "body": { "name":"Identifier", "string": "foo" }
        }
      """

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
              "name": "ExpAtom",
              "body": {
                "name": "Identifier",
                "string": "foo"
              }
            },
            {
              "name": "ExpAtom",
              "body": {
                "name": "LiteralInteger",
                "kind": "DecimalInteger",
                "value": 1
              }
            },
            {
              "name": "ExpAtom",
              "body": {
                "name": "LiteralBool",
                "value": true
              }
            }
          ]
        }
      """

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, "foo; 1; true", expected1)])

class iso _TestParserExpressionAssignment is UnitTest
  fun name(): String => "parser/expression/Assignment"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item()

    let expected =
      """
        {
          "name": "ExpOperation",
          "op": { "name": "Token", "string": "=" },
          "lhs": {
            "name": "ExpAtom",
            "body": { "name": "Identifier", "string": "foo" }
          },
          "rhs": {
            "name": "ExpAtom",
            "body": {
              "name": "LiteralInteger",
              "value": 123
            }
          }
        }
      """

    _Assert.test_all(h,
      [ _Assert.test_match(h, rule, setup.data, "foo = 123", expected)])

class iso _TestParserExpressionJump is UnitTest
  fun name(): String => "parser/expression/Jump"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item()

    let source1 = "return 3.14"
    let expected1 =
      """
        {
          "name": "ExpJump",
          "keyword": {
            "name": "Keyword",
            "string": "return"
          },
          "rhs": {
            "name": "ExpAtom",
            "body": {
              "name": "LiteralFloat",
              "value": 3.14
            }
          }
        }
      """

    let source2 = "error"
    let expected2 =
      """
        {
          "name": "ExpJump",
          "keyword": {
            "name": "Keyword",
            "string": "error"
          }
        }
      """

    _Assert.test_all(h,
      [ _Assert.test_match(h, rule, setup.data, source1, expected1)
        _Assert.test_match(h, rule, setup.data, source2, expected2) ])

class iso _TestParserExpressionInfix is UnitTest
  fun name(): String => "parser/expression/Infix"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item()

    let source1 = "a as C"
    let expected1 =
      """
        {
          "name": "ExpOperation",
          "lhs": {
            "name": "ExpAtom",
            "body": {
              "name": "Identifier",
              "string": "a"
            }
          },
          "op": {
            "name": "Keyword",
            "string": "as"
          },
          "rhs": {
            "name": "TypeNominal",
            "rhs": {
              "name": "Identifier",
              "string": "C"
            }
          }
        }
      """

    let source2 = "a *? b"
    let expected2 =
      """
        {
          "name": "ExpOperation",
          "lhs": {
            "name": "ExpAtom",
            "body": {
              "name": "Identifier",
              "string": "a"
            }
          },
          "op": {
            "name": "Token",
            "string": "*"
          },
          "rhs": {
            "name": "ExpAtom",
            "body": {
              "name": "Identifier",
              "string": "b"
            }
          },
          "partial": true
        }
      """

    _Assert.test_all(h,
      [ _Assert.test_match(h, rule, setup.data, source1, expected1)
        _Assert.test_match(h, rule, setup.data, source2, expected2) ])

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
                  {
                    "name": "ExpAtom",
                    "body": { "name": "LiteralBool", "value": true }
                  }
                ]
              },
              "then_block": {
                "name": "ExpSequence",
                "expressions": [
                  {
                    "name": "ExpAtom",
                    "body": { "name": "Identifier", "string": "foo" }
                  }
                ]
              }
            },
            {
              "if_true": {
                "name": "ExpSequence",
                "expressions": [
                  {
                    "name": "ExpAtom",
                    "body": { "name": "LiteralBool", "value": false }
                  }
                ]
              },
              "then_block": {
                "name": "ExpSequence",
                "expressions": [
                  {
                    "name": "ExpAtom",
                    "body": { "name": "Identifier", "string": "bar" }
                  }
                ]
              }
            }
          ],
          "else_block": {
            "name": "ExpSequence",
            "expressions": [
              {
                "name": "ExpAtom",
                "body": { "name": "Identifier", "string": "baz" }
              }
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
                  {
                    "name": "ExpAtom",
                    "body": { "name": "Identifier", "string": "windows" }
                  }
                ]
              },
              "then_block": {
                "name": "ExpSequence",
                "expressions": [
                  {
                    "name": "ExpAtom",
                    "body": { "name": "Identifier", "string": "foo" }
                  }
                ]
              }
            },
            {
              "if_true": {
                "name": "ExpSequence",
                "expressions": [
                  {
                    "name": "ExpAtom",
                    "body": { "name": "Identifier", "string": "unix" }
                  }
                ]
              },
              "then_block": {
                "name": "ExpSequence",
                "expressions": [
                  {
                    "name": "ExpAtom",
                    "body": { "name": "Identifier", "string": "bar" }
                  }
                ]
              }
            }
          ],
          "else_block": {
            "name": "ExpSequence",
            "expressions": [
              {
                "name": "ExpAtom",
                "body": { "name": "Identifier", "string": "baz" }
              }
            ]
          }
        }
      """

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])

class iso _TestParserExpressionPrefix is UnitTest
  fun name(): String => "parser/expression/Prefix"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item()

    let source = "not true"
    let expected =
      """
        {
          "name": "ExpOperation",
          "op": {
            "name": "Keyword",
            "string": "not"
          },
          "rhs": {
            "name": "ExpAtom",
            "body": {
              "name": "LiteralBool",
              "value": true
            }
          }
        }
      """

    _Assert.test_all(h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])

class iso _TestParserExpressionPostfix is UnitTest
  fun name(): String => "parser/expression/Postfix"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item()

    let source1 = "a.b"
    let expected1 =
      """
        {
          "name": "ExpOperation",
          "lhs": {
            "name": "ExpAtom",
            "body": { "name": "Identifier", "string": "a" }
          },
          "op": {
            "name": "Token",
            "string": "."
          },
          "rhs": {
            "name": "Identifier",
            "string": "b"
          }
        }
      """

    let source2 = "a[T]"
    let expected2 =
      """
        {
          "name": "ExpGeneric",
          "lhs": {
            "name": "ExpAtom",
            "body": { "name": "Identifier", "string": "a" }
          },
          "type_args": {
            "name": "TypeArgs",
            "types": [
              {
                "name": "TypeNominal",
                "rhs": { "name": "Identifier", "string": "T" }
              }
            ]
          }
        }
      """

    let source3 = "a(3.14, b where c = true, d = \"z\")?"
    let expected3 =
      """
        {
          "name": "ExpCall",
          "lhs": {
            "name": "ExpAtom",
            "body": { "name": "Identifier", "string": "a" }
          },
          "partial": true,
          "args": {
            "name": "CallArgs",
            "positional": [
              {
                "name": "ExpSequence",
                "expressions": [
                  {
                    "name": "ExpAtom",
                    "body": { "name": "LiteralFloat", "value": 3.14 }
                  }
                ]
              },
              {
                "name": "ExpSequence",
                "expressions": [
                  {
                    "name": "ExpAtom",
                    "body": { "name": "Identifier", "string": "b" }
                  }
                ]
              }
            ],
            "named": [
              {
                "name": "ExpOperation",
                "lhs": { "name": "Identifier", "string": "c" },
                "op": { "name": "Token", "string": "=" },
                "rhs": {
                  "name": "ExpSequence",
                  "expressions": [
                    {
                      "name": "ExpAtom",
                      "body": { "name": "LiteralBool", "value": true }
                    }
                  ]
                }
              },
              {
                "name": "ExpOperation",
                "lhs": { "name": "Identifier", "string": "d" },
                "op": { "name": "Token", "string": "=" },
                "rhs": {
                  "name": "ExpSequence",
                  "expressions": [
                    {
                      "name": "ExpAtom",
                      "body": {
                        "name": "LiteralString",
                        "value": "z"
                      }
                    }
                  ]
                }
              }
            ]
          }
        }
      """

    _Assert.test_all(h,
      [ _Assert.test_match(h, rule, setup.data, source1, expected1)
        _Assert.test_match(h, rule, setup.data, source2, expected2)
        _Assert.test_match(h, rule, setup.data, source3, expected3) ])

class iso _TestParserExpressionTuple is UnitTest
  fun name(): String => "parser/expression/Tuple"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item()

    let source = "(a, 1, this)"
    let expected =
      """
        {
          "name": "ExpTuple",
          "sequences": [
            {
              "name": "ExpSequence",
              "expressions": [
                {
                  "name": "ExpAtom",
                  "body": { "name": "Identifier", "string": "a" }
                }
              ]
            },
            {
              "name": "ExpSequence",
              "expressions": [
                {
                  "name": "ExpAtom",
                  "body": { "name": "LiteralInteger", "value": 1 }
                }
              ]
            },
            {
              "name": "ExpSequence",
              "expressions": [
                {
                  "name": "ExpAtom",
                  "body": { "name": "Keyword", "string": "this" }
                }
              ]
            }
          ]
        }
      """

    _Assert.test_all(h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])

class iso _TestParserExpressionParens is UnitTest
  fun name(): String => "parser/expression/Parens"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item()

    let source = "(1.23)"
    let expected =
      """
        {
          "name": "ExpSequence",
          "expressions": [
            {
              "name": "ExpAtom",
              "body": {
                "name": "LiteralFloat",
                "value": 1.23
              }
            }
          ]
        }
      """

    _Assert.test_all(h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])

class iso _TestParserExpressionRecover is UnitTest
  fun name(): String => "parser/expression/Recover"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item()

    let source = "recover trn a; 123 end"
    let expected =
      """
        {
          "name": "ExpRecover",
          "cap": {
            "name": "Keyword",
            "string": "trn"
          },
          "body": {
            "name": "ExpSequence",
            "expressions": [
              {
                "name": "ExpAtom",
                "body": { "name": "Identifier", "string": "a" }
              },
              {
                "name": "ExpAtom",
                "body": { "name": "LiteralInteger", "value": 123 }
              }
            ]
          }
        }
      """

    _Assert.test_all(h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])

class iso _TestParserExpressionTry is UnitTest
  fun name(): String => "parser/expression/Try"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item()

    let source = "try a else 123 end"
    let expected =
      """
        {
          "name": "ExpTry",
          "body": {
            "name": "ExpSequence",
            "expressions": [
              {
                "name": "ExpAtom",
                "body": { "name": "Identifier", "string": "a" }
              }
            ]
          },
          "else_block": {
            "name": "ExpSequence",
            "expressions": [
              {
                "name": "ExpAtom",
                "body": { "name": "LiteralInteger", "value": 123 }
              }
            ]
          }
        }
      """

    _Assert.test_all(h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])

class iso _TestParserExpressionArray is UnitTest
  fun name(): String => "parser/expression/Array"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item()

    let source1 = "[ as USize: 1; 2 ]"
    let expected1 =
      """
        {
          "name": "ExpArray",
          "type": {
            "name": "TypeNominal",
            "rhs": { "name": "Identifier", "string": "USize" }
          },
          "body": {
            "name": "ExpSequence",
            "expressions": [
              {
                "name": "ExpAtom",
                "body": { "name": "LiteralInteger", "value": 1 }
              },
              {
                "name": "ExpAtom",
                "body": { "name": "LiteralInteger", "value": 2 }
              }
            ]
          }
        }
      """

    let source2 = "[ a\n\tb ]"
    let expected2 =
      """
        {
          "name": "ExpArray",
          "body": {
            "name": "ExpSequence",
            "expressions": [
              {
                "name": "ExpAtom",
                "body": { "name": "Identifier", "string": "a" }
              },
              {
                "name": "ExpAtom",
                "body": { "name": "Identifier", "string": "b" }
              }
            ]
          }
        }
      """

    _Assert.test_all(h,
      [ _Assert.test_match(h, rule, setup.data, source1, expected1)
        _Assert.test_match(h, rule, setup.data, source2, expected2) ])

class iso _TestParserExpressionConsume is UnitTest
  fun name(): String => "parser/expression/Consume"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item()

    let source = "consume iso (a + 4)"
    let expected =
      """
        {
          "name": "ExpConsume",
          "cap": { "name": "Keyword", "string": "iso" },
          "body": {
            "name": "ExpSequence",
            "expressions": [
              {
                "name": "ExpOperation",
                "op": { "name": "Token", "string": "+" },
                "lhs": {
                  "name": "ExpAtom",
                  "body": { "name": "Identifier", "string": "a" }
                },
                "rhs": {
                  "name": "ExpAtom",
                  "body": { "name": "LiteralInteger", "value": 4 }
                }
              }
            ]
          }
        }
      """

    _Assert.test_all(h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])

class iso _TestParserExpressionWhile is UnitTest
  fun name(): String => "parser/expression/While"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item()

    let source = "while 1 == 2 do f(a) else g.b end"
    let expected =
      """
        {
          "name": "ExpWhile",
          "condition": {
            "name": "ExpSequence",
            "expressions": [
              {
                "name": "ExpOperation",
                "lhs": {
                  "name": "ExpAtom",
                  "body": { "name": "LiteralInteger", "value": 1 }
                },
                "op": { "name": "Token", "string": "==" },
                "rhs": {
                  "name": "ExpAtom",
                  "body": { "name": "LiteralInteger", "value": 2 }
                }
              }
            ]
          },
          "body": {
            "name": "ExpSequence",
            "expressions": [
              {
                "name": "ExpCall",
                "lhs": {
                  "name": "ExpAtom",
                  "body": { "name": "Identifier", "string": "f" }
                },
                "args": {
                  "name": "CallArgs",
                  "positional": [
                    {
                      "name": "ExpSequence",
                      "expressions": [
                        {
                          "name": "ExpAtom",
                          "body": { "name": "Identifier", "string": "a" }
                        }
                      ]
                    }
                  ]
                }
              }
            ]
          },
          "else_block": {
            "name": "ExpSequence",
            "expressions": [
              {
                "name": "ExpOperation",
                "lhs": {
                  "name": "ExpAtom",
                  "body": { "name": "Identifier", "string": "g" }
                },
                "op": { "name": "Token", "string": "." },
                "rhs": { "name": "Identifier", "string": "b" }
              }
            ]
          }
        }
      """

    _Assert.test_all(h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])

class iso _TestParserExpressionRepeat is UnitTest
  fun name(): String => "parser/expression/Repeat"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item()

    let source = "repeat a until b else c end"
    let expected =
      """
        {
          "name": "ExpRepeat",
          "body": {
            "name": "ExpSequence",
            "expressions": [
              {
                "name": "ExpAtom",
                "body": { "name": "Identifier", "string": "a" }
              }
            ]
          },
          "condition": {
            "name": "ExpSequence",
            "expressions": [
              {
                "name": "ExpAtom",
                "body": { "name": "Identifier", "string": "b" }
              }
            ]
          },
          "else_block": {
            "name": "ExpSequence",
            "expressions": [
              {
                "name": "ExpAtom",
                "body" : { "name": "Identifier", "string": "c" }
              }
            ]
          }
        }
      """

    _Assert.test_all(h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])

class iso _TestParserExpressionFor is UnitTest
  fun name(): String => "parser/expression/For"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item()

    let source = "for (a, b) in c else d end"
    let expected =
      """
        {
          "name": "ExpFor",
          "ids": [
            { "name": "Identifier", "string": "a" },
            { "name": "Identifier", "string": "b" }
          ],
          "body": {
            "name": "ExpSequence",
            "expressions": [
              {
                "name": "ExpAtom",
                "body": { "name": "Identifier", "string": "c" }
              }
            ]
          },
          "else_block": {
            "name": "ExpSequence",
            "expressions": [
              {
                "name": "ExpAtom",
                "body": { "name": "Identifier", "string": "d" }
              }
            ]
          }
        }
      """

    _Assert.test_all(h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])

  class iso _TestParserExpressionMatch is UnitTest
    fun name(): String => "parser/expression/Match"
    fun exclusion_group(): String => "parser/expression"

    fun apply(h: TestHelper) =>
      let setup = _TestSetup(name())
      let rule = setup.builder.expression.item()

      let source =
        """
          match a
          | b if c => d
          | 2 => true
          else
            g
          end
        """
      let expected =
        """
          {
            "name": "ExpMatch",
            "expression": {
              "name": "ExpSequence",
              "expressions": [
                {
                  "name": "ExpAtom",
                  "body": { "name": "Identifier", "string": "a" }
                }
              ]
            },
            "cases": [
              {
                "name": "MatchCase",
                "pattern": {
                  "name": "ExpAtom",
                  "body": { "name": "Identifier", "string": "b" }
                },
                "condition": {
                  "name": "ExpSequence",
                  "expressions": [
                    {
                      "name": "ExpAtom",
                      "body": { "name": "Identifier", "string": "c" }
                    }
                  ]
                },
                "body": {
                  "name": "ExpSequence",
                  "expressions": [
                    {
                      "name": "ExpAtom",
                      "body": { "name": "Identifier", "string": "d" }
                    }
                  ]
                }
              },
              {
                "name": "MatchCase",
                "pattern": {
                  "name": "ExpAtom",
                  "body": { "name": "LiteralInteger", "value": 2 }
                },
                "body": {
                  "name": "ExpSequence",
                  "expressions": [
                    {
                      "name": "ExpAtom",
                      "body": { "name": "LiteralBool", "value": true }
                    }
                  ]
                }
              }
            ],
            "else_block": {
              "name": "ExpSequence",
              "expressions": [
                {
                  "name": "ExpAtom",
                  "body": { "name": "Identifier", "string": "g" }
                }
              ]
            }
          }
        """

    _Assert.test_all(h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])

  class iso _TestParserExpressionDecl is UnitTest
    fun name(): String => "parser/expression/Decl"
    fun exclusion_group(): String => "parser/expression"

    fun apply(h: TestHelper) =>
      let setup = _TestSetup(name())
      let rule = setup.builder.expression.item()

      let source1 = "let n: F32"
      let expected1 =
        """
          {
            "name": "ExpDecl",
            "identifier": { "name": "Identifier", "string": "n" },
            "decl_type": {
              "name": "TypeNominal",
              "rhs": { "name": "Identifier", "string": "F32" }
            }
          }
        """

      let source2 = "let n: F32 = 3.14"
      let expected2 =
        """
          {
            "name": "ExpOperation",
            "lhs": {
              "name": "ExpDecl",
              "identifier": { "name": "Identifier", "string": "n" },
              "decl_type": {
                "name": "TypeNominal",
                "rhs": { "name": "Identifier", "string": "F32" }
              }
            },
            "op": { "name": "Token", "string": "=" },
            "rhs": {
              "name": "ExpAtom",
              "body": { "name": "LiteralFloat", "value": 3.14 }
            }
          }
        """

    _Assert.test_all(h,
      [ _Assert.test_match(h, rule, setup.data, source1, expected1)
        _Assert.test_match(h, rule, setup.data, source2, expected2) ])

  class iso _TestParserExpressionWith is UnitTest
    fun name(): String => "parser/expression/With"
    fun exclusion_group(): String => "parser/expression"

    fun apply(h: TestHelper) =>
      let setup = _TestSetup(name())
      let rule = setup.builder.expression.item()

      let source = "with (a, b) = c, d = e do f end"
      let expected =
        """
          {
            "name": "ExpWith",
            "elements": [
              {
                "name": "WithElement",
                "ids": [
                  { "name": "Identifier", "string": "a" },
                  { "name": "Identifier", "string": "b" }
                ],
                "body": {
                  "name": "ExpSequence",
                  "expressions": [
                    {
                      "name": "ExpAtom",
                      "body": { "name": "Identifier", "string": "c" }
                    }
                  ]
                }
              },
              {
                "name": "WithElement",
                "ids": [
                  { "name": "Identifier", "string": "d" }
                ],
                "body": {
                  "name": "ExpSequence",
                  "expressions": [
                    {
                      "name": "ExpAtom",
                      "body": { "name": "Identifier", "string": "e" }
                    }
                  ]
                }
              }
            ],
            "body": {
              "name": "ExpSequence",
              "expressions": [
                {
                  "name": "ExpAtom",
                  "body": { "name": "Identifier", "string": "f" }
                }
              ]
            }
          }
        """

    _Assert.test_all(h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])
