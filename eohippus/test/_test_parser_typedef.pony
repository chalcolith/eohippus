use "pony_test"

use ast = "../ast"
use json = "../json"
use parser = "../parser"
use ".."

primitive _TestParserTypedef
  fun apply(test: PonyTest) =>
    test(_TestParserTypedefPrimitiveSimple)

class iso _TestParserTypedefPrimitiveSimple is UnitTest
  fun name(): String => "parser/typedef/Primitive/simple"
  fun exclusion_group(): String => "parser/typedef"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.typedef.typedef_primitive()

    let source = "primitive FooBar\n\"\"\"docs\"\"\"  "
    let expected =
      """
        {
          "name": "TypeDefPrimitive",
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
