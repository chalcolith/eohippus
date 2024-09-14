use "pony_test"

use ast = "../ast"
use json = "../json"
use parser = "../parser"
use ".."

primitive _TestParserTypedef
  fun apply(test: PonyTest) =>
    test(_TestParserTypedefField)
    test(_TestParserTypedefMethod)
    test(_TestParserTypedefMethodBare)
    test(_TestParserTypedefMethodComplex)
    test(_TestParserTypedefMethodNegation)
    test(_TestParserTypedefMethodSequence)
    test(_TestParserTypedefMembers)
    test(_TestParserTypedefPrimitive)
    test(_TestParserTypedefPrimitiveMethods)
    test(_TestParserTypedefAlias)
    test(_TestParserTypedefClass)

class iso _TestParserTypedefField is UnitTest
  fun name(): String => "parser/typedef/Field"
  fun exclusion_group(): String => "parser/typedef"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.typedef.field

    let src = "let foo: USize = 123 \"\"\"doc\"\"\""
    let exp = """
      {
        "name": "TypedefField",
        "kind": 0,
        "identifier": 1,
        "type": 3,
        "initializer": 5,
        "doc_strings": [
          6
        ],
        "children": [
          {
            "name": "Keyword",
            "string": "let"
          },
          {
            "name": "Identifier",
            "string": "foo"
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
                "string": "USize"
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
          },
          {
            "name": "DocString",
            "string": 0,
            "children": [
              {
                "name": "LiteralString",
                "kind": "StringTripleQuote",
                "value": "doc",
                "children": [
                  {
                    "name": "Token",
                    "string": "\"\"\""
                  },
                  {
                    "name": "Span"
                  },
                  {
                    "name": "Token",
                    "string": "\"\"\""
                  }
                ]
              }
            ]
          }
        ]
      }
    """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])

class iso _TestParserTypedefMethod is UnitTest
  fun name(): String => "parser/typedef/Method/simple"
  fun exclusion_group(): String => "parser/typedef"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.typedef.method

    let src =
      """
        fun \ann\ ref name[A](p: B): USize ? =>
          "doc"
          1 + 2
          a
      """
    let exp = """
      {
        "name": "TypedefMethod",
        "annotation": 1,
        "kind": 0,
        "cap": 2,
        "identifier": 3,
        "type_params": 4,
        "params": 6,
        "return_type": 9,
        "partial": true,
        "body": 12,
        "children": [
          {
            "name": "Keyword",
            "string": "fun"
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
                "string": "ann"
              },
              {
                "name": "Token",
                "string": "\\"
              }
            ]
          },
          {
            "name": "Keyword",
            "string": "ref"
          },
          {
            "name": "Identifier",
            "string": "name"
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
                        "string": "A"
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
              0
            ],
            "children": [
              {
                "name": "MethodParam",
                "identifier": 0,
                "constraint": 2,
                "children": [
                  {
                    "name": "Identifier",
                    "string": "p"
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
                        "string": "B"
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
            "string": ":"
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
            "string": "?"
          },
          {
            "name": "Token",
            "string": "=>"
          },
          {
            "name": "ExpSequence",
            "expressions": [ 0, 1, 2 ],
            "children": [
              {
                "name": "ExpAtom",
                "body": 0,
                "children": [ { "name": "LiteralString", "value": "doc" } ]
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
                    "string": "+"
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
              }
            ]
          }
        ]
      }
    """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])

class iso _TestParserTypedefMethodBare is UnitTest
  fun name(): String => "parser/typedef/Method/bare"
  fun exclusion_group(): String => "parser/typedef"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.typedef.method

    let src = "be writev(data: ByteSeqIter)\n  \"\"\"\n  Write an iterable collection of ByteSeqs.\n  \"\"\"\n"
    let exp =
      """
        {
          "name": "TypedefMethod",
          "kind": 0,
          "identifier": 1,
          "params": 3,
          "doc_strings": [ 5 ]
        }
      """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])

class iso _TestParserTypedefMethodNegation is UnitTest
  fun name(): String => "parser/typedef/Method/negation"
  fun exclusion_group(): String => "parser/typedef"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.typedef.method

    let src =
      """
        fun foo() =>
          "doc"
          -123
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

class iso _TestParserTypedefMethodComplex is UnitTest
  fun name(): String => "parser/typedef/Method/complex"
  fun exclusion_group(): String => "parser/typedef"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.typedef.method

    let src =
      """
        fun fld[T: (SignedInteger[T, U] val & Signed), U: UnsignedInteger[U] val](x: T, y: T): T =>
          if (y == T.from[U8](0)) or ((x == T.min_value()) and (y == T.from[I8](-1))) then
            T.from[U8](0)
          else
            _SignedUnsafeArithmetic.fld_unsafe[T, U](x, y)
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

class iso _TestParserTypedefMethodSequence is UnitTest
  fun name(): String => "parser/typedef/Method/sequence"
  fun exclusion_group(): String => "parser/typedef"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.typedef.method

    let src =
      """
        fun _u64(x: U64, neg: Bool): String iso^ =>
          let table = "0123456789"
          let base: U64 = 10

          recover
            var s = String(31)
            var value = x

            try
              if value == 0 then
                s.push(table(0)?)
              else
                while value != 0 do
                  let index = ((value = value / base) - (value * base))
                  s.push(table(index.usize())?)
                end
              end
            end

            if neg then s.push('-') end
            s .> reverse_in_place()
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

class iso _TestParserTypedefMembers is UnitTest
  fun name(): String => "parser/typedef/Members"
  fun exclusion_group(): String => "parser/typedef"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.typedef.members

    let src = """
      let a: USize
      fun b() => None
    """

    let exp = """
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
                "string": "a"
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
                    "string": "USize"
                  }
                ]
              }
            ]
          },
          {
            "name": "TypedefMethod",
            "kind": 0,
            "identifier": 1,
            "body": 5,
            "children": [
              {
                "name": "Keyword",
                "string": "fun"
              },
              {
                "name": "Identifier",
                "string": "b"
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
                "string": "=>"
              },
              {
                "name": "ExpAtom",
                "body": 0,
                "children": [
                  {
                    "name": "Identifier",
                    "string": "None"
                  }
                ]
              }
            ]
          }
        ]
      }
    """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])

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

class iso _TestParserTypedefPrimitiveMethods is UnitTest
  fun name(): String => "parser/typedef/Primitive/methods"
  fun exclusion_group(): String => "parser/typedef"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.typedef.typedef_primitive

    let src =
      """
        primitive Foo is Stringable
          fun fld[T: (SignedInteger[T, U] val & Signed), U: UnsignedInteger[U] val](x: T, y: T): T =>
            if (y == T.from[U8](0)) or ((x == T.min_value()) and (y == T.from[I8](-1))) then
              T.from[U8](0)
            else
              _SignedUnsafeArithmetic.fld_unsafe[T, U](x, y)
            end
      """

    let src_len = src.size()

    _Assert.test_all(
      h,
      [ _Assert.test_with(
          h, rule, setup.data, src,
          {(success, value) =>
            let len = success.next.index() - success.start.index()
            ( len == src_len
            , "expected length " + src_len.string() + ", got " + len.string())
          })
      ])

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
