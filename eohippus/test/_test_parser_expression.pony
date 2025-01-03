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
    test(_TestParserExpressionIfExpression)
    test(_TestParserExpressionIfComplex)
    test(_TestParserExpressionSequence)
    test(_TestParserExpressionJump)
    test(_TestParserExpressionInfix)
    test(_TestParserExpressionPrefix)
    test(_TestParserExpressionPostfix)
    test(_TestParserExpressionTuple)
    test(_TestParserExpressionParens)
    test(_TestParserExpressionRecover)
    test(_TestParserExpressionTry)
    test(_TestParserExpressionTryEmpty)
    test(_TestParserExpressionArray)
    test(_TestParserExpressionConsume)
    test(_TestParserExpressionWhile)
    test(_TestParserExpressionRepeat)
    test(_TestParserExpressionTuplePattern)
    test(_TestParserExpressionFor)
    test(_TestParserExpressionMatch)
    test(_TestParserExpressionMatchFallThrough)
    test(_TestParserExpressionMatchNegative)
    test(_TestParserExpressionDecl)
    test(_TestParserExpressionWith)
    test(_TestParserExpressionFfi)
    test(_TestParserExpressionLambda)
    test(_TestParserExpressionLambda2)
    test(_TestParserExpressionObject)

class iso _TestParserExpressionIdentifier is UnitTest
  fun name(): String => "parser/expression/Identifier"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.token.identifier

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
    let rule = setup.builder.expression.item

    let exp =
      """
        {
          "name": "ExpAtom",
          "body": 0,
          "children": [
            { "name":"Identifier", "string": "foo" }
          ]
        }
      """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, "foo", exp) ])

class iso _TestParserExpressionSequence is UnitTest
  fun name(): String => "parser/expression/Sequence"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.seq

    let src = "foo; 1; true"
    let exp =
      """
        {
          "name": "ExpSequence",
          "expressions": [ 0, 2, 4 ],
          "children": [
            {
              "name": "ExpAtom",
              "body": 0,
              "children": [
                { "name": "Identifier", "string": "foo" }
              ]
            },
            { "name": "Token", "string": ";" },
            {
              "name": "ExpAtom",
              "body": 0,
              "children": [
                {
                  "name": "LiteralInteger",
                  "kind": "DecimalInteger",
                  "value": 1
                }
              ]
            },
            { "name": "Token", "string": ";" },
            {
              "name": "ExpAtom",
              "body": 0,
              "children": [
                { "name": "LiteralBool", "value": true }
              ]
            }
          ]
        }
      """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp)])

class iso _TestParserExpressionAssignment is UnitTest
  fun name(): String => "parser/expression/Assignment"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item

    let src = "foo = 123"
    let exp =
      """
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
                {
                  "name": "Identifier",
                  "string": "foo"
                }
              ]
            },
            {
              "name": "Token",
              "string": "="
            },
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
      """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp)])

class iso _TestParserExpressionJump is UnitTest
  fun name(): String => "parser/expression/Jump"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item

    let source1 = "return 3.14"
    let expected1 =
      """
        {
          "name": "ExpJump",
          "keyword": 0,
          "rhs": 1,
          "children": [
            { "name": "Keyword", "string": "return" },
            {
              "name": "ExpAtom",
              "body": 0,
              "children": [
                { "name": "LiteralFloat", "value": 3.14 }
              ]
            }
          ]
        }
      """

    let source2 = "error"
    let expected2 =
      """
        {
          "name": "ExpJump",
          "keyword": 0,
          "children": [
            { "name": "Keyword", "string": "error" }
          ]
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
    let rule = setup.builder.expression.item

    let source1 = "a as C"
    let expected1 =
      """
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
                { "name": "Identifier", "string": "a" }
              ]
            },
            { "name": "Keyword", "string": "as" },
            {
              "name": "TypeNominal",
              "rhs": 0,
              "children": [
                { "name": "Identifier", "string": "C" }
              ]
            }
          ]
        }
      """

    let source2 = "a *? b"
    let expected2 =
      """
        {
          "name": "ExpOperation",
          "partial": true,
          "lhs": 0,
          "op": 1,
          "rhs": 3,
          "children": [
            {
              "name": "ExpAtom",
              "body": 0,
              "children": [
                { "name": "Identifier", "string": "a" }
              ]
            },
            { "name": "Token", "string": "*" },
            { "name": "Token", "string": "?" },
            {
              "name": "ExpAtom",
              "body": 0,
              "children": [
                { "name": "Identifier", "string": "b" }
              ]
            }
          ]
        }
      """

    _Assert.test_all(h,
      [ _Assert.test_match(h, rule, setup.data, source1, expected1)
        _Assert.test_match(h, rule, setup.data, source2, expected2) ])

class iso _TestParserExpressionIf is UnitTest
  fun name(): String => "parser/expression/If/simple"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item

    let src =
      """
        if true then
          foo
        elseif false then
          bar
        else
          baz
        end
      """
    let exp =
      """
        {
          "name": "ExpIf",
          "kind": "IfExp",
          "conditions": [ 1, 3 ],
          "else_block": 5,
          "children": [
            { "name": "Keyword", "string": "if" },
            {
              "name": "IfCondition",
              "if_true": 0,
              "then_block": 2,
              "children": [
                {
                  "name": "ExpAtom",
                  "body": 0,
                  "children": [
                    { "name": "LiteralBool", "value": true }
                  ]
                },
                { "name": "Keyword", "string": "then" },
                {
                  "name": "ExpAtom",
                  "body": 0,
                  "children": [
                    { "name": "Identifier", "string": "foo" }
                  ]
                }
              ]
            },
            { "name": "Keyword", "string": "elseif" },
            {
              "name": "IfCondition",
              "if_true": 0,
              "then_block": 2,
              "children": [
                {
                  "name": "ExpAtom",
                  "body": 0,
                  "children": [
                    { "name": "LiteralBool", "value": false }
                  ]
                },
                { "name": "Keyword", "string": "then" },
                {
                  "name": "ExpAtom",
                  "body": 0,
                  "children": [
                    { "name": "Identifier", "string": "bar" }
                  ]
                }
              ]
            },
            { "name": "Keyword", "string": "else" },
            {
              "name": "ExpAtom",
              "body": 0,
              "children": [
                { "name": "Identifier", "string": "baz" }
              ]
            },
            { "name": "Keyword", "string": "end" }
          ]
        }
      """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])

class iso _TestParserExpressionIfExpression is UnitTest
  fun name(): String => "parser/expression/If/expression"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item

    let src =
      """
        if value == 1 then
          true
        end
      """
    let exp =
      """
        {
          "name": "ExpIf",
          "kind": "IfExp",
          "conditions": [ 1 ],
          "children": [
            {
              "name": "Keyword",
              "string": "if"
            },
            {
              "name": "IfCondition",
              "if_true": 0,
              "then_block": 2,
              "children": [
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
                        {
                          "name": "Identifier",
                          "string": "value"
                        }
                      ]
                    },
                    {
                      "name": "Token",
                      "string": "=="
                    },
                    {
                      "name": "ExpAtom",
                      "body": 0,
                      "children": [
                        {
                          "name": "LiteralInteger",
                          "kind": "DecimalInteger",
                          "value": 1
                        }
                      ]
                    }
                  ]
                },
                {
                  "name": "Keyword",
                  "string": "then"
                },
                {
                  "name": "ExpAtom",
                  "body": 0,
                  "children": [
                    {
                      "name": "LiteralBool",
                      "value": true
                    }
                  ]
                }
              ]
            },
            {
              "name": "Keyword",
              "string": "end"
            }
          ]
        }
      """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])

class iso _TestParserExpressionIfComplex is UnitTest
  fun name(): String => "parser/expression/If/complex"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item

    let src =
      """
        if a and not b then
          c
        end
      """
    let exp =
      """
        {
          "name": "ExpIf",
          "conditions": [ 1 ],
          "children": [
            { "name": "Keyword", "string": "if" },
            {
              "name": "IfCondition",
              "if_true": 0,
              "then_block": 2,
              "children": [
                {
                  "name": "ExpOperation",
                  "lhs": 0,
                  "op": 1,
                  "rhs": 2,
                  "children": [
                    { "name": "ExpAtom" },
                    { "name": "Keyword", "string": "and" },
                    {
                      "name": "ExpOperation",
                      "op": 0,
                      "rhs": 1,
                      "children": [
                        { "name": "Keyword", "string": "not" },
                        { "name": "ExpAtom" }
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

class iso _TestParserExpressionIfDef is UnitTest
  fun name(): String => "parser/expression/IfDef"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item

    let src =
      """
        ifdef windows then
          foo
        elseif unix then
          bar
        else
          baz
        end
      """
    let exp =
      """
        {
          "name": "ExpIf",
          "kind": "IfDef",
          "conditions": [
            1,
            3
          ],
          "else_block": 5,
          "children": [
            {
              "name": "Keyword",
              "string": "ifdef"
            },
            {
              "name": "IfCondition",
              "if_true": 0,
              "then_block": 2,
              "children": [
                {
                  "name": "ExpAtom",
                  "body": 0,
                  "children": [
                    {
                      "name": "Identifier",
                      "string": "windows"
                    }
                  ]
                },
                {
                  "name": "Keyword",
                  "string": "then"
                },
                {
                  "name": "ExpAtom",
                  "body": 0,
                  "children": [
                    {
                      "name": "Identifier",
                      "string": "foo"
                    }
                  ]
                }
              ]
            },
            {
              "name": "Keyword",
              "string": "elseif"
            },
            {
              "name": "IfCondition",
              "if_true": 0,
              "then_block": 2,
              "children": [
                {
                  "name": "ExpAtom",
                  "body": 0,
                  "children": [
                    {
                      "name": "Identifier",
                      "string": "unix"
                    }
                  ]
                },
                {
                  "name": "Keyword",
                  "string": "then"
                },
                {
                  "name": "ExpAtom",
                  "body": 0,
                  "children": [
                    {
                      "name": "Identifier",
                      "string": "bar"
                    }
                  ]
                }
              ]
            },
            {
              "name": "Keyword",
              "string": "else"
            },
            {
              "name": "ExpAtom",
              "body": 0,
              "children": [
                {
                  "name": "Identifier",
                  "string": "baz"
                }
              ]
            },
            {
              "name": "Keyword",
              "string": "end"
            }
          ]
        }
      """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])

class iso _TestParserExpressionPrefix is UnitTest
  fun name(): String => "parser/expression/Prefix"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item

    let source = "not true"
    let expected =
      """
        {
          "name": "ExpOperation",
          "op": 0,
          "rhs": 1,
          "children": [
            { "name": "Keyword", "string": "not" },
            {
              "name": "ExpAtom",
              "body": 0,
              "children": [
                { "name": "LiteralBool", "value": true }
              ]
            }
          ]
        }
      """

    _Assert.test_all(h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])

class iso _TestParserExpressionPostfix is UnitTest
  fun name(): String => "parser/expression/Postfix"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item

    let source1 = "a.b"
    let expected1 =
      """
        {
          "name": "ExpOperation",
          "lhs": 0,
          "op": 1,
          "rhs": 2,
          "children": [
            {
              "name": "ExpAtom",
              "body": 0,
              "children": [ { "name": "Identifier", "string": "a" } ]
            },
            { "name": "Token", "string": "." },
            { "name": "Identifier", "string": "b" }
          ]
        }
      """

    let source2 = "a[T]"
    let expected2 =
      """
        {
          "name": "ExpGeneric",
          "lhs": 0,
          "type_args": 1,
          "children": [
            {
              "name": "ExpAtom",
              "body": 0,
              "children": [ { "name": "Identifier", "string": "a" } ]
            },
            {
              "name": "TypeArgs",
              "types": [ 1 ],
              "children": [
                { "name": "Token" },
                {
                  "name": "TypeNominal",
                  "rhs": 0,
                  "children": [
                    { "name": "Identifier", "string": "T" }
                  ]
                },
                { "name": "Token" }
              ]
            }
          ]
        }
      """

    let source3 = "a(3.14, b where c = true, d = \"z\")?"
    let expected3 =
      """
        {
          "name": "ExpCall",
          "lhs": 0,
          "args": 1,
          "partial": true,
          "children": [
            {
              "name": "ExpAtom",
              "body": 0,
              "children": [
                {
                  "name": "Identifier",
                  "string": "a"
                }
              ]
            },
            {
              "name": "CallArgs",
              "positional": [
                1,
                3
              ],
              "named": [
                5,
                7
              ],
              "children": [
                {
                  "name": "Token",
                  "string": "("
                },
                {
                  "name": "ExpAtom",
                  "body": 0,
                  "children": [
                    {
                      "name": "LiteralFloat",
                      "value": 3.14
                    }
                  ]
                },
                {
                  "name": "Token",
                  "string": ","
                },
                {
                  "name": "ExpAtom",
                  "body": 0,
                  "children": [
                    {
                      "name": "Identifier",
                      "string": "b"
                    }
                  ]
                },
                {
                  "name": "Keyword",
                  "string": "where"
                },
                {
                  "name": "ExpOperation",
                  "lhs": 0,
                  "op": 1,
                  "rhs": 2,
                  "children": [
                    {
                      "name": "Identifier",
                      "string": "c"
                    },
                    {
                      "name": "Token",
                      "string": "="
                    },
                    {
                      "name": "ExpAtom",
                      "body": 0,
                      "children": [
                        {
                          "name": "LiteralBool",
                          "value": true
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
                  "name": "ExpOperation",
                  "lhs": 0,
                  "op": 1,
                  "rhs": 2,
                  "children": [
                    {
                      "name": "Identifier",
                      "string": "d"
                    },
                    {
                      "name": "Token",
                      "string": "="
                    },
                    {
                      "name": "ExpAtom",
                      "body": 0,
                      "children": [
                        {
                          "name": "LiteralString",
                          "kind": "StringLiteral",
                          "value": "z"
                        }
                      ]
                    }
                  ]
                },
                {
                  "name": "Token",
                  "string": ")"
                }
              ]
            },
            {
              "name": "Token",
              "string": "?"
            }
          ]
        }
      """

    let source4 = "a .> b(1)"
    let expected4 =
      """
        {
          "name": "ExpCall",
          "lhs": 0,
          "args": 1,
          "children": [
            {
              "name": "ExpOperation"
            }
          ]
        }
      """

    _Assert.test_all(h,
      [ _Assert.test_match(h, rule, setup.data, source1, expected1)
        _Assert.test_match(h, rule, setup.data, source2, expected2)
        _Assert.test_match(h, rule, setup.data, source3, expected3)
        _Assert.test_match(h, rule, setup.data, source4, expected4) ])

class iso _TestParserExpressionTuple is UnitTest
  fun name(): String => "parser/expression/Tuple/expression"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item

    let src = "(a, 1, this)"
    let exp =
      """
        {
          "name": "ExpTuple",
          "sequences": [ 1, 3, 5 ],
          "children": [
            { "name": "Token" },
            {
              "name": "ExpAtom",
              "body": 0,
              "children": [ { "name": "Identifier", "string": "a" } ]
            },
            { "name": "Token" },
            {
              "name": "ExpAtom",
              "body": 0,
              "children": [ { "name": "LiteralInteger", "value": 1 } ]
            },
            { "name": "Token" },
            {
              "name": "ExpAtom",
              "body": 0,
              "children": [ { "name": "Keyword", "string": "this" } ]
            },
            { "name": "Token" }
          ]
        }
      """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])

class iso _TestParserExpressionParens is UnitTest
  fun name(): String => "parser/expression/Parens"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item

    let src = "(1.23)"
    let exp =
      """
        {
          "name": "ExpAtom",
          "body": 1,
          "children": [
            {
              "name": "Token",
              "string": "(",
            },
            {
              "name": "ExpAtom",
              "body": 0,
              "children": [
                {
                  "name": "LiteralFloat",
                  "value": 1.23
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

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])

class iso _TestParserExpressionRecover is UnitTest
  fun name(): String => "parser/expression/Recover"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item

    let src = "recover trn a; 123 end"
    let exp =
      """
        {
          "name": "ExpRecover",
          "cap": 1,
          "body": 2,
          "children": [
            { "name": "Keyword", "string": "recover" },
            { "name": "Keyword", "string": "trn" },
            {
              "name": "ExpSequence",
              "expressions": [ 0, 2 ],
              "children": [
                {
                  "name": "ExpAtom",
                  "body": 0,
                  "children": [ { "name": "Identifier", "string": "a" } ]
                },
                { "name": "Token", "string": ";" },
                {
                  "name": "ExpAtom",
                  "body": 0,
                  "children": [ { "name": "LiteralInteger", "value": 123 } ]
                }
              ]
            }
          ]
        }
      """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])

class iso _TestParserExpressionTry is UnitTest
  fun name(): String => "parser/expression/Try"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item

    let src = "try a else 123 end"
    let exp =
      """
        {
          "name": "ExpTry",
          "body": 1,
          "else_block": 3,
          "children": [
            { "name": "Keyword", "string": "try" },
            {
              "name": "ExpAtom",
              "body": 0,
              "children": [ { "name": "Identifier", "string": "a" } ]
            },
            { "name": "Keyword", "string": "else" },
            {
              "name": "ExpAtom",
              "body": 0,
              "children": [ { "name": "LiteralInteger", "value": 123 } ]
            },
            { "name": "Keyword", "string": "end" }
          ]
        }
      """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])

class iso _TestParserExpressionTryEmpty is UnitTest
  fun name(): String => "parser/expression/Try/empty"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item

    let src = "try end"
    let exp =
      """
        {
          "name": "ExpTry",
          "children": [
            { "name": "Keyword", "string": "try" },
            { "name": "ErrorSection" },
            { "name": "Keyword", "string": "end" }
          ]
        }
      """

    _Assert.test_all(
      h,
      [ _Assert.test_match(
        h, rule, setup.data, src, exp where ignore_error_sections = true) ])

class iso _TestParserExpressionArray is UnitTest
  fun name(): String => "parser/expression/Array"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item

    let source1 = "[ as USize: 1; 2 ]"
    let expected1 =
      """
        {
          "name": "ExpArray",
          "type": 2,
          "body": 4,
          "children": [
            {
              "name": "Token",
              "string": "["
            },
            {
              "name": "Keyword",
              "string": "as"
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
              "string": ":"
            },
            {
              "name": "ExpSequence",
              "expressions": [
                0,
                2
              ],
              "children": [
                {
                  "name": "ExpAtom",
                  "body": 0,
                  "children": [
                    {
                      "name": "LiteralInteger",
                      "kind": "DecimalInteger",
                      "value": 1
                    }
                  ]
                },
                {
                  "name": "Token",
                  "string": ";"
                },
                {
                  "name": "ExpAtom",
                  "body": 0,
                  "children": [
                    {
                      "name": "LiteralInteger",
                      "kind": "DecimalInteger",
                      "value": 2
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
        }
      """

    let source2 = "[ a\n\tb ]"
    let expected2 =
      """
        {
          "name": "ExpArray",
          "body": 1,
          "children": [
            {
              "name": "Token",
              "string": "["
            },
            {
              "name": "ExpSequence",
              "expressions": [
                0,
                1
              ],
              "children": [
                {
                  "name": "ExpAtom",
                  "body": 0,
                  "children": [
                    {
                      "name": "Identifier",
                      "string": "a"
                    }
                  ]
                },
                {
                  "name": "ExpAtom",
                  "body": 0,
                  "children": [
                    {
                      "name": "Identifier",
                      "string": "b"
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
        }
      """

    let source3 = "[]"
    let expected3 =
      """
        {
          "name": "ExpArray",
          "children": [
            {
              "name": "Token", "string": "["
            },
            {
              "name": "Token", "string": "]"
            }
          ]
        }
      """

    _Assert.test_all(h,
      [ _Assert.test_match(h, rule, setup.data, source1, expected1)
        _Assert.test_match(h, rule, setup.data, source2, expected2)
        _Assert.test_match(h, rule, setup.data, source3, expected3) ])

class iso _TestParserExpressionConsume is UnitTest
  fun name(): String => "parser/expression/Consume"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item

    let src = "consume iso a"
    let exp =
      """
        {
          "name": "ExpConsume",
          "cap": 1,
          "body": 2,
          "children": [
            {
              "name": "Keyword",
              "string": "consume"
            },
            {
              "name": "Keyword",
              "string": "iso"
            },
            {
              "name": "ExpAtom",
              "body": 0,
              "children": [
                {
                  "name": "Identifier",
                  "string": "a"
                }
              ]
            }
          ]
        }
      """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])

class iso _TestParserExpressionWhile is UnitTest
  fun name(): String => "parser/expression/While"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item

    let src = "while 1 == 2 do f(a) else g.b end"
    let exp =
      """
        {
          "name": "ExpWhile",
          "condition": 1,
          "body": 3,
          "else_block": 5,
          "children": [
            {
              "name": "Keyword",
              "string": "while"
            },
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
                    {
                      "name": "LiteralInteger",
                      "kind": "DecimalInteger",
                      "value": 1
                    }
                  ]
                },
                {
                  "name": "Token",
                  "string": "=="
                },
                {
                  "name": "ExpAtom",
                  "body": 0,
                  "children": [
                    {
                      "name": "LiteralInteger",
                      "kind": "DecimalInteger",
                      "value": 2
                    }
                  ]
                }
              ]
            },
            {
              "name": "Keyword",
              "string": "do"
            },
            {
              "name": "ExpCall",
              "lhs": 0,
              "args": 1,
              "children": [
                {
                  "name": "ExpAtom",
                  "body": 0,
                  "children": [
                    {
                      "name": "Identifier",
                      "string": "f"
                    }
                  ]
                },
                {
                  "name": "CallArgs",
                  "positional": [
                    1
                  ],
                  "children": [
                    {
                      "name": "Token",
                      "string": "("
                    },
                    {
                      "name": "ExpAtom",
                      "body": 0,
                      "children": [
                        {
                          "name": "Identifier",
                          "string": "a"
                        }
                      ]
                    },
                    {
                      "name": "Token",
                      "string": ")"
                    }
                  ]
                }
              ]
            },
            {
              "name": "Keyword",
              "string": "else"
            },
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
                    {
                      "name": "Identifier",
                      "string": "g"
                    }
                  ]
                },
                {
                  "name": "Token",
                  "string": "."
                },
                {
                  "name": "Identifier",
                  "string": "b"
                }
              ]
            },
            {
              "name": "Keyword",
              "string": "end"
            }
          ]
        }
      """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])

class iso _TestParserExpressionRepeat is UnitTest
  fun name(): String => "parser/expression/Repeat"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item

    let src = "repeat a until b else c end"
    let exp =
      """
        {
          "name": "ExpRepeat",
          "body": 1,
          "condition": 3,
          "else_block": 5,
          "children": [
            {
              "name": "Keyword",
              "string": "repeat"
            },
            {
              "name": "ExpAtom",
              "body": 0,
              "children": [
                {
                  "name": "Identifier",
                  "string": "a"
                }
              ]
            },
            {
              "name": "Keyword",
              "string": "until"
            },
            {
              "name": "ExpAtom",
              "body": 0,
              "children": [
                {
                  "name": "Identifier",
                  "string": "b"
                }
              ]
            },
            {
              "name": "Keyword",
              "string": "else"
            },
            {
              "name": "ExpAtom",
              "body": 0,
              "children": [
                {
                  "name": "Identifier",
                  "string": "c"
                }
              ]
            },
            {
              "name": "Keyword",
              "string": "end"
            }
          ]
        }
      """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])

class iso _TestParserExpressionTuplePattern is UnitTest
  fun name(): String => "parser/expression/TuplePattern"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.tuple_pattern

    let src = "(a, (b, c))"
    let exp =
      """
        {
          "name": "TuplePattern",
          "elements": [
            1,
            3
          ],
          "children": [
            {
              "name": "Token",
              "string": "("
            },
            {
              "name": "TuplePattern",
              "elements": [
                0
              ],
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
              "name": "TuplePattern",
              "elements": [
                1,
                3
              ],
              "children": [
                {
                  "name": "Token",
                  "string": "("
                },
                {
                  "name": "TuplePattern",
                  "elements": [
                    0
                  ],
                  "children": [
                    {
                      "name": "Identifier",
                      "string": "b"
                    }
                  ]
                },
                {
                  "name": "Token",
                  "string": ","
                },
                {
                  "name": "TuplePattern",
                  "elements": [
                    0
                  ],
                  "children": [
                    {
                      "name": "Identifier",
                      "string": "c"
                    }
                  ]
                },
                {
                  "name": "Token",
                  "string": ")"
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
    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])

class iso _TestParserExpressionFor is UnitTest
  fun name(): String => "parser/expression/For"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item

    let src = "for (a, b) in c do d else e end"
    let exp =
      """
        {
          "name": "ExpFor",
          "pattern": 1,
          "sequence": 3,
          "body": 5,
          "else_block": 7,
          "children": [
            {
              "name": "Keyword",
              "string": "for"
            },
            {
              "name": "TuplePattern",
              "elements": [
                1,
                3
              ],
              "children": [
                {
                  "name": "Token",
                  "string": "("
                },
                {
                  "name": "TuplePattern",
                  "elements": [
                    0
                  ],
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
                  "name": "TuplePattern",
                  "elements": [
                    0
                  ],
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
            },
            {
              "name": "Keyword",
              "string": "in"
            },
            {
              "name": "ExpAtom",
              "body": 0,
              "children": [
                {
                  "name": "Identifier",
                  "string": "c"
                }
              ]
            },
            {
              "name": "Keyword",
              "string": "do"
            },
            {
              "name": "ExpAtom",
              "body": 0,
              "children": [
                {
                  "name": "Identifier",
                  "string": "d"
                }
              ]
            },
            {
              "name": "Keyword",
              "string": "else"
            },
            {
              "name": "ExpAtom",
              "body": 0,
              "children": [
                {
                  "name": "Identifier",
                  "string": "e"
                }
              ]
            },
            {
              "name": "Keyword",
              "string": "end"
            }
          ]
        }
      """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])

class iso _TestParserExpressionMatch is UnitTest
  fun name(): String => "parser/expression/Match"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item

    let src =
      """
        match a
        | b if c => d
        | 2 => true
        else
          g
        end
      """
    let exp =
      """
        {
          "name": "ExpMatch",
          "expression": 1,
          "cases": [ 2, 3 ],
          "else_block": 5,
          "children": [
            {
              "name": "Keyword",
              "string": "match"
            },
            {
              "name": "ExpAtom",
              "body": 0,
              "children": [
                {
                  "name": "Identifier",
                  "string": "a"
                }
              ]
            },
            {
              "name": "MatchCase",
              "patterns": [ 0 ],
              "body": 2,
              "children": [
                {
                  "name": "MatchPattern",
                  "pattern": 1,
                  "condition": 3,
                  "children": [
                    { "name": "Token", "string": "|" },
                    {
                      "name": "ExpAtom",
                      "body": 0,
                      "children": [ { "name": "Identifier", "string": "b" } ]
                    },
                    { "name": "Keyword", "string": "if" },
                    {
                      "name": "ExpAtom",
                      "body": 0,
                      "children": [ { "name": "Identifier", "string": "c" } ]
                    }
                  ]
                },
                {
                  "name": "Token", "string": "=>"
                },
                {
                  "name": "ExpAtom",
                  "body": 0,
                  "children": [ { "name": "Identifier", "string": "d" } ]
                }
              ]
            },
            {
              "name": "MatchCase",
              "patterns": [ 0 ],
              "body": 2,
              "children": [
                {
                  "name": "MatchPattern",
                  "pattern": 1,
                  "children": [
                    { "name": "Token", "string": "|" },
                    {
                      "name": "ExpAtom",
                      "body": 0,
                      "children": [ { "name": "LiteralInteger", "value": 2 } ]
                    }
                  ]
                },
                { "name": "Token", "string": "=>" },
                {
                  "name": "ExpAtom",
                  "body": 0,
                  "children": [ { "name": "LiteralBool", "value": true } ]
                }
              ]
            },
            {
              "name": "Keyword",
              "string": "else"
            },
            {
              "name": "ExpAtom",
              "body": 0,
              "children": [
                {
                  "name": "Identifier",
                  "string": "g"
                }
              ]
            },
            {
              "name": "Keyword",
              "string": "end"
            }
          ]
        }
      """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])

class iso _TestParserExpressionMatchFallThrough is UnitTest
  fun name(): String => "parser/expression/Match/fallthrough"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item

    let src =
      """
        match foo
        | ';' | '#' =>
          continue
        end
      """
    let src_len = src.size()

    _Assert.test_all(
      h,
      [ _Assert.test_with(
          h, rule, setup.data, src,
          {(success, values) =>
            let len = success.next.index() - success.start.index()
            ( len == src_len
            , "expected length " + src_len.string() + ", got " + len.string() )
          })
      ])

class iso _TestParserExpressionMatchNegative is UnitTest
  fun name(): String => "parser/expression/Match/negative"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item

    let src =
      """
        match a
        | -1 => b
        | let c: U32 => d
        end
      """

    let src_len = src.size()

    _Assert.test_all(
      h,
      [ _Assert.test_with(
          h, rule, setup.data, src,
          {(success, values) =>
            let len = success.next.index() - success.start.index()
            ( len == src_len
            , "expected length " + src_len.string() + ", got " + len.string() )
          })
      ])

class iso _TestParserExpressionDecl is UnitTest
  fun name(): String => "parser/expression/Decl"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item

    let source1 = "let n: F32"
    let expected1 =
      """
        {
          "name": "ExpDecl",
          "kind": 0,
          "identifier": 1,
          "decl_type": 3,
          "children": [
            {
              "name": "Keyword",
              "string": "let"
            },
            {
              "name": "Identifier",
              "string": "n"
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
            }
          ]
        }
      """

    let source2 = "let n: F32 = 3.14"
    let expected2 =
      """
        {
          "name": "ExpOperation",
          "lhs": 0,
          "op": 1,
          "rhs": 2,
          "children": [
            {
              "name": "ExpDecl",
              "kind": 0,
              "identifier": 1,
              "decl_type": 3,
              "children": [
                {
                  "name": "Keyword",
                  "string": "let"
                },
                {
                  "name": "Identifier",
                  "string": "n"
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
                }
              ]
            },
            {
              "name": "Token",
              "string": "="
            },
            {
              "name": "ExpAtom",
              "body": 0,
              "children": [
                {
                  "name": "LiteralFloat",
                  "value": 3.14
                }
              ]
            }
          ]
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
    let rule = setup.builder.expression.item

    let src = "with (a, b) = c, d = e do f end"
    let exp =
      """
        {
          "name": "ExpWith",
          "elements": [
            1,
            3
          ],
          "body": 5,
          "children": [
            {
              "name": "Keyword",
              "string": "with"
            },
            {
              "name": "WithElement",
              "pattern": 0,
              "body": 2,
              "children": [
                {
                  "name": "TuplePattern",
                  "elements": [
                    1,
                    3
                  ],
                  "children": [
                    {
                      "name": "Token",
                      "string": "("
                    },
                    {
                      "name": "TuplePattern",
                      "elements": [
                        0
                      ],
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
                      "name": "TuplePattern",
                      "elements": [
                        0
                      ],
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
                },
                {
                  "name": "Token",
                  "string": "="
                },
                {
                  "name": "ExpAtom",
                  "body": 0,
                  "children": [
                    {
                      "name": "Identifier",
                      "string": "c"
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
              "name": "WithElement",
              "pattern": 0,
              "body": 2,
              "children": [
                {
                  "name": "TuplePattern",
                  "elements": [
                    0
                  ],
                  "children": [
                    {
                      "name": "Identifier",
                      "string": "d"
                    }
                  ]
                },
                {
                  "name": "Token",
                  "string": "="
                },
                {
                  "name": "ExpAtom",
                  "body": 0,
                  "children": [
                    {
                      "name": "Identifier",
                      "string": "e"
                    }
                  ]
                }
              ]
            },
            {
              "name": "Keyword",
              "string": "do"
            },
            {
              "name": "ExpAtom",
              "body": 0,
              "children": [
                {
                  "name": "Identifier",
                  "string": "f"
                }
              ]
            },
            {
              "name": "Keyword",
              "string": "end"
            }
          ]
        }
      """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])

class iso _TestParserExpressionFfi is UnitTest
  fun name(): String => "parser/expression/Ffi"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item

    let src = "@a[T](b)?"
    let exp =
      """
        {
          "name": "ExpFfi",
          "identifier": 1,
          "type_args": 2,
          "call_args": 3,
          "partial": true,
          "children": [
            {
              "name": "Token",
              "string": "@"
            },
            {
              "name": "Identifier",
              "string": "a"
            },
            {
              "name": "TypeArgs",
              "types": [
                1
              ],
              "children": [
                {
                  "name": "Token",
                  "string": "["
                },
                {
                  "name": "TypeNominal",
                  "rhs": 0,
                  "children": [
                    {
                      "name": "Identifier",
                      "string": "T"
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
              "name": "CallArgs",
              "positional": [
                1
              ],
              "children": [
                {
                  "name": "Token",
                  "string": "("
                },
                {
                  "name": "ExpAtom",
                  "body": 0,
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
            },
            {
              "name": "Token",
              "string": "?"
            }
          ]
        }
      """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])

class iso _TestParserExpressionLambda2 is UnitTest
  fun name(): String => "parser/expression/Lambda2"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item

    let src = "{ () ? => one }"
    let src_len = src.size()

    _Assert.test_all(
      h,
      [ _Assert.test_with(
          h, rule, setup.data, src,
          {(success, values) =>
            let len = success.next.index() - success.start.index()
            ( len == src_len
            , "expected length " + src_len.string() + ", got " + len.string() )
          })
      ])

class iso _TestParserExpressionLambda is UnitTest
  fun name(): String => "parser/expression/Lambda"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item

    //            0                15   20   25   30   35   40   45
    let src = "@{ \\z\\ iso a[T](b:U=c,d:V)(e,f):W? => g; h } trn"
    let exp =
      """
        {
          "name": "ExpLambda",
          "annotation": 2,
          "bare": true,
          "this_cap": 3,
          "identifier": 4,
          "type_params": 5,
          "params": 7,
          "captures": 10,
          "ret_type": 13,
          "partial": true,
          "body": 16,
          "ref_cap": 18,
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
              "name": "Annotation",
              "identifiers": [
                1
              ],
              "children": [
                {
                  "name": "Token",
                  "string": "\\"
                },
                {
                  "name": "Identifier",
                  "string": "z"
                },
                {
                  "name": "Token",
                  "string": "\\"
                }
              ]
            },
            {
              "name": "Keyword",
              "string": "iso"
            },
            {
              "name": "Identifier",
              "string": "a"
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
              "name": "Token",
              "string": "("
            },
            {
              "name": "MethodParams",
              "params": [
                0,
                2
              ],
              "children": [
                {
                  "name": "MethodParam",
                  "identifier": 0,
                  "constraint": 2,
                  "initializer": 4,
                  "children": [
                    {
                      "name": "Identifier",
                      "string": "b"
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
                          "string": "U"
                        }
                      ]
                    },
                    {
                      "name": "Token",
                      "string": "="
                    },
                    {
                      "name": "ExpAtom",
                      "body": 0,
                      "children": [
                        {
                          "name": "Identifier",
                          "string": "c"
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
                  "name": "MethodParam",
                  "identifier": 0,
                  "constraint": 2,
                  "children": [
                    {
                      "name": "Identifier",
                      "string": "d"
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
                          "string": "V"
                        }
                      ]
                    }
                  ]
                }
              ]
            },
            {
              "name": "Token",
              "string": ")"
            },
            {
              "name": "Token",
              "string": "("
            },
            {
              "name": "MethodParams",
              "params": [
                0,
                2
              ],
              "children": [
                {
                  "name": "MethodParam",
                  "identifier": 0,
                  "children": [
                    {
                      "name": "Identifier",
                      "string": "e"
                    }
                  ]
                },
                {
                  "name": "Token",
                  "string": ","
                },
                {
                  "name": "MethodParam",
                  "identifier": 0,
                  "children": [
                    {
                      "name": "Identifier",
                      "string": "f"
                    }
                  ]
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
                  "string": "W"
                }
              ]
            },
            {
              "name": "Token",
              "string": "?"
            },
            {
              "name": "Token",
              "string": "=>"
            },
            {
              "name": "ExpSequence",
              "expressions": [
                0,
                2
              ],
              "children": [
                {
                  "name": "ExpAtom",
                  "body": 0,
                  "children": [
                    {
                      "name": "Identifier",
                      "string": "g"
                    }
                  ]
                },
                {
                  "name": "Token",
                  "string": ";"
                },
                {
                  "name": "ExpAtom",
                  "body": 0,
                  "children": [
                    {
                      "name": "Identifier",
                      "string": "h"
                    }
                  ]
                }
              ]
            },
            {
              "name": "Token",
              "string": "}"
            },
            {
              "name": "Keyword",
              "string": "trn"
            }
          ]
        }
      """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])

class iso _TestParserExpressionObject is UnitTest
  fun name(): String => "parser/expression/Object"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item

    let src = """
      object is B
        let c: D
        fun e(): F => g
      end
    """
    let exp = """
        {
          "name": "ExpObject",
          "constraint": 2,
          "members": 3,
          "children": [
            {
              "name": "Keyword",
              "string": "object"
            },
            {
              "name": "Keyword",
              "string": "is"
            },
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
              "name": "TypedefMembers",
              "fields": [
                0
              ],
              "methods": [
                1
              ],
              "children": [
                {
                  "name": "TypedefField",
                  "kind": 0,
                  "identifier": 1,
                  "type": 3,
                  "children": [
                    {
                      "name": "Keyword",
                      "string": "let"
                    },
                    {
                      "name": "Identifier",
                      "string": "c"
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
                          "string": "D"
                        }
                      ]
                    }
                  ]
                },
                {
                  "name": "TypedefMethod",
                  "kind": 0,
                  "identifier": 1,
                  "return_type": 5,
                  "body": 7,
                  "children": [
                    {
                      "name": "Keyword",
                      "string": "fun"
                    },
                    {
                      "name": "Identifier",
                      "string": "e"
                    },
                    {
                      "name": "Token",
                      "string": "("
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
                          "string": "F"
                        }
                      ]
                    },
                    {
                      "name": "Token",
                      "string": "=>"
                    },
                    {
                      "name": "ExpAtom",
                      "body": 0,
                      "children": [
                        {
                          "name": "Identifier",
                          "string": "g"
                        }
                      ]
                    }
                  ]
                }
              ]
            },
            {
              "name": "Keyword",
              "string": "end"
            }
          ]
        }
    """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])
