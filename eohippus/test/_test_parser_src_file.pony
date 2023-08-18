use "itertools"
use "pony_test"

use ast = "../ast"
use json = "../json"
use parser = "../parser"
use ".."

primitive _TestParserSrcFile
  fun apply(test: PonyTest) =>
    test(_TestParserSrcFileTriviaDocstring)
    test(_TestParserSrcFileUsingSingle)
    test(_TestParserSrcFileUsingErrorSection)

class iso _TestParserSrcFileTriviaDocstring is UnitTest
  fun name(): String => "parser/src_file/SrcFile/Trivia+Docstring"
  fun exclusion_group(): String => "parser/src_file"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.src_file.src_file()

    let expected =
      """
        {
          "name": "SrcFile",
          "locator": "parser/src_file/SrcFile/Trivia+Docstring",
          "usings": [],
          "type_defs": [],
          "doc_strings": [
            {
              "name": "DocString",
              "string": {
                "name": "LiteralString",
                "kind": "StringTripleQuote",
                "value": "This is a doc string\n"
              }
            }
          ],
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
          ]
        }
      """
    let source = "\n // trivia!\n \"\"\"\n This is a doc string\n \"\"\" \t"

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])

class iso _TestParserSrcFileUsingSingle is UnitTest
  fun name(): String => "parser/src_file/SrcFile/Using/single"
  fun exclusion_group(): String => "parser/src_file"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.src_file.src_file()

    let expected =
      """
      """

    let source = " use \"foo\" if windows\nuse baz = \"bar\" if not osx"

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])

class iso _TestParserSrcFileUsingErrorSection is UnitTest
  fun name(): String => "parser/src_file/SrcFile/Using/error_section"
  fun exclusion_group(): String => "parser/src_file"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.src_file.src_file()
    h.fail()

    // let code =
    //   """
    //     // comment
    //     use "bar"

    //     gousbnfg

    //     use "baz"
    //   """
    // let len = code.size()

    // let src1 = setup.src(code)
    // let loc1 = parser.Loc(src1)
    // let inf1 = ast.SrcInfo(setup.data.locator(), loc1, loc1 + len)

    // _Assert.test_all(h, [
    //   _Assert.test_match(h, rule, src1, 0, setup.data, true, len, None, None,
    //     {(node: ast.Node) =>
    //       try
    //         let src_file = node as ast.SrcFile
    //         let usings = src_file.usings()

    //         (h.assert_eq[USize](2, usings.size())) and
    //         (Iter[ast.Node](src_file.children().values())
    //           .filter_map[ast.ErrorSection](
    //             {(child) => try child as ast.ErrorSection end})
    //           .count() == 1)
    //       else
    //         false
    //       end
    //     })
    // ])
