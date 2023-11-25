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
  fun name(): String => "parser/type/TypeArrow"
  fun exclusion_group(): String => "parser/type"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.type_type.arrow

    let source = "this->N"
    let expected =
      """
        {
          "name": "TypeArrow",
          "lhs": {
            "name": "TypeAtom",
            "body": {
              "name": "Keyword",
              "string": "this"
            }
          },
          "rhs": {
            "name": "TypeNominal",
            "rhs": {
              "name": "Identifier",
              "string": "N"
            }
          }
        }
      """

    _Assert.test_all(h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])

class iso _TestParserTypeAtom is UnitTest
  fun name(): String => "parser/type/TypeAtom"
  fun exclusion_group(): String => "parser/type"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.type_type.atom

    let source1 = "this"
    let expected1 =
      """
        { "name": "TypeAtom", "body": { "name": "Keyword", "string": "this" } }
      """

    let source2 = "trn"
    let expected2 =
      """
        { "name": "TypeAtom", "body": { "name": "Keyword", "string": "trn" } }
      """

    let source3 = "(a, b)"
    let expected3 =
      """
        {
          "name": "TypeTuple",
          "types": [
            {
              "name": "TypeNominal",
              "rhs": {
                "name": "Identifier",
                "string": "a"
              }
            },
            {
              "name": "TypeNominal",
              "rhs": {
                "name": "Identifier",
                "string": "b"
              }
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

    let source = "(a & (b | c))"
    let expected =
      """
        {
          "name": "TypeInfix",
          "op": { "name": "Token", "string": "&" },
          "types": [
            {
              "name": "TypeNominal",
              "rhs": {
                "name": "Identifier",
                "string": "a"
              }
            },
            {
              "name": "TypeInfix",
              "op": { "name": "Token", "string": "|" },
              "types": [
                {
                  "name": "TypeNominal",
                  "rhs": {
                    "name": "Identifier",
                    "string": "b"
                  }
                },
                {
                  "name": "TypeNominal",
                  "rhs": {
                    "name": "Identifier",
                    "string": "c"
                  }
                }
              ]
            }
          ]
        }
      """

    _Assert.test_all(h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])

class iso _TestParserTypeNominal is UnitTest
  fun name(): String => "parser/type/Nominal"
  fun exclusion_group(): String => "parser/type"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.type_type.nominal

    let source = "p.t[N] iso^"
    let expected =
      """
        {
          "name": "TypeNominal",
          "lhs": { "name": "Identifier", "string": "p" },
          "rhs": { "name": "Identifier", "string": "t" },
          "params": {
              "name": "TypeParams",
              "params": [
                {
                  "name": "TypeParam",
                  "constraint": {
                    "name": "TypeNominal",
                    "rhs": {
                      "name": "Identifier",
                      "string": "N"
                    }
                  }
                }
              ]
            },
          "cap": { "name": "Keyword", "string": "iso" },
          "eph": { "name": "Token", "string": "^" }
        }
      """

    _Assert.test_all(h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])

class iso _TestParserTypeLambda is UnitTest
  fun name(): String => "parser/type/Lambda"
  fun exclusion_group(): String => "parser/type"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.type_type.arrow

    let source = "@{ref foo[A,B](USize,Bool):F32?} trn!"
    let expected =
      """
        {
          "name": "TypeLambda",
          "bare": true,
          "cap": { "name": "Keyword", "string": "ref" },
          "identifier": { "name": "Identifier", "string": "foo" },
          "type_params": {
            "name": "TypeParams",
            "params": [
              {
                "name": "TypeParam",
                "constraint": {
                  "name": "TypeNominal",
                  "rhs": { "name": "Identifier", "string": "A" }
                }
              },
              {
                "name": "TypeParam",
                "constraint": {
                  "name": "TypeNominal",
                  "rhs": { "name": "Identifier", "string": "B" }
                }
              }
            ]
          },
          "param_types": [
            {
              "name": "TypeNominal",
              "rhs": { "name": "Identifier", "string": "USize" }
            },
            {
              "name": "TypeNominal",
              "rhs": { "name": "Identifier", "string": "Bool" }
            }
          ],
          "return_type": {
            "name": "TypeNominal",
            "rhs": { "name": "Identifier", "string": "F32" }
          },
          "partial": true,
          "rcap": { "name": "Keyword", "string": "trn" },
          "reph": { "name": "Token", "string": "!" }
        }
      """

    _Assert.test_all(h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])
