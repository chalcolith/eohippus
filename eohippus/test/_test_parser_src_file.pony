use "itertools"
use "pony_test"

use ast = "../ast"
use json = "../json"
use parser = "../parser"
use ".."

primitive _TestParserSrcFile
  fun apply(test: PonyTest) =>
    test(_TestParserSrcFileTriviaDocstring)
    test(_TestParserSrcFileUsingPony)
    test(_TestParserSrcFileUsingFfi)
    test(_TestParserSrcFileUsingErrorSection)

class iso _TestParserSrcFileTriviaDocstring is UnitTest
  fun name(): String => "parser/src_file/SrcFile/Trivia+Docstring"
  fun exclusion_group(): String => "parser/src_file"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.src_file.src_file

    let expected =
      """
        {
          "name": "SrcFile",
          "locator": "parser/src_file/SrcFile/Trivia+Docstring",
          "pre_trivia": [
            {
              "name": "Trivia",
              "kind": "EndOfLineTrivia"
            },
            {
              "name": "Trivia",
              "kind": "WhiteSpaceTrivia"
            },
            {
              "name": "Trivia",
              "kind": "LineCommentTrivia"
            },
            {
              "name": "Trivia",
              "kind": "EndOfLineTrivia"
            },
            {
              "name": "Trivia",
              "kind": "WhiteSpaceTrivia"
            }
          ],
          "doc_strings": [
            {
              "name": "DocString",
              "string": {
                "name": "LiteralString",
                "kind": "StringTripleQuote",
                "value": "This is a doc string\n",
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
    let source = "\n // trivia!\n \"\"\"\n This is a doc string\n \"\"\" \t"

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])

class iso _TestParserSrcFileUsingPony is UnitTest
  fun name(): String => "parser/src_file/Using/Pony"
  fun exclusion_group(): String => "parser/src_file"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.src_file.src_file

    let source = " use \"foo\" if windows\nuse baz = \"bar\" if not osx"

    let expected =
      """
        {
          "name": "SrcFile",
          "locator": "parser/src_file/Using/Pony",
          "usings": [
            {
              "name": "Using",
              "path": {
                "name": "LiteralString",
                "kind": "StringLiteral",
                "value": "foo",
                "post_trivia": [
                  {
                    "name": "Trivia",
                    "kind": "WhiteSpaceTrivia"
                  }
                ]
              },
              "define": {
                "name": "Identifier",
                "string": "windows",
                "post_trivia": [
                  {
                    "name": "Trivia",
                    "kind": "EndOfLineTrivia"
                  }
                ]
              }
            },
            {
              "name": "Using",
              "identifier": {
                "name": "Identifier",
                "string": "baz",
                "post_trivia": [
                  {
                    "name": "Trivia",
                    "kind": "WhiteSpaceTrivia"
                  }
                ]
              },
              "path": {
                "name": "LiteralString",
                "kind": "StringLiteral",
                "value": "bar",
                "post_trivia": [
                  {
                    "name": "Trivia",
                    "kind": "WhiteSpaceTrivia"
                  }
                ]
              },
              "def_true": false,
              "define": {
                "name": "Identifier",
                "string": "osx"
              }
            }
          ],
          "pre_trivia": [
            {
              "name": "Trivia",
              "kind": "WhiteSpaceTrivia"
            }
          ]
        }
      """

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])

class iso _TestParserSrcFileUsingFfi is UnitTest
  fun name(): String => "parser/src_file/Using/FFI"
  fun exclusion_group(): String => "parser/src_file"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.src_file.src_file

    let source = " use a = @b[None](c: U8) ? "
    let expected = """
      {
        "name": "SrcFile",
        "usings": [
          {
            "identifier": { "string": "a" },
            "name": { "string": "b" },
            "type_args": {
              "types": [
                {
                  "rhs": { "string": "None" }
                }
              ]
            },
            "params": {
              "params": [
                {
                  "identifier": { "string": "c" },
                  "constraint": { "rhs": { "string": "U8" } }
                }
              ]
            },
            "partial": true
          }
        ]
      }
    """

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])


class iso _TestParserSrcFileUsingErrorSection is UnitTest
  fun name(): String => "parser/src_file/SrcFile/Using/error_section"
  fun exclusion_group(): String => "parser/src_file"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.src_file.src_file

    let expected =
      """
        {
          "name": "SrcFile",
          "locator": "parser/src_file/SrcFile/Using/error_section",
          "usings": [
            {
              "name": "Using",
              "path": {
                "name": "LiteralString",
                "kind": "StringLiteral",
                "value": "bar",
                "post_trivia": [
                  {
                    "name": "Trivia",
                    "kind": "EndOfLineTrivia"
                  },
                  {
                    "name": "Trivia",
                    "kind": "EndOfLineTrivia"
                  }
                ]
              }
            },
            {
              "name": "Using",
              "path": {
                "name": "LiteralString",
                "kind": "StringLiteral",
                "value": "baz",
                "post_trivia": [
                  {
                    "name": "Trivia",
                    "kind": "EndOfLineTrivia"
                  }
                ]
              }
            }
          ],
          "error_sections": [
            {
              "name": "ErrorSection",
              "message": "expected either a \"use\" statement or a type definition"
            }
          ],
          "pre_trivia": [
            {
              "name": "Trivia",
              "kind": "LineCommentTrivia"
            },
            {
              "name": "Trivia",
              "kind": "EndOfLineTrivia"
            }
          ]
        }
      """

    //            0           11         20  22      30  32  36       42
    let source = "// comment\nuse \"bar\"\n\ngousbnfg\n\nuse \"baz\"\n"

    _Assert.test_all(h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])
