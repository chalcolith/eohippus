use "pony_test"

use ast = "../ast"
use parser = "../parser"
use ".."

primitive _TestParserSrcFile
  fun apply(test: PonyTest) =>
    test(_TestParserSrcFileTriviaDocstring)

class iso _TestParserSrcFileTriviaDocstring is UnitTest
  fun name(): String => "parser/src_file/SrcFile/trivia+docstring"
  fun exclusion_group(): String => "parser/src_file"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.src_file()

    let code = "\n // trivia!\n \"\"\"\n This is a doc string\n \"\"\" \t"
    let len = code.size()

    let src1 = setup.src(code)
    let loc1 = parser.Loc(src1)
    let inf1 = ast.SrcInfo(setup.data.locator(), loc1, loc1 + len)

    _Assert.test_all(h, [
      _Assert.test_match(h, rule, src1, 0, setup.data, true, len, None, None,
        {(node: ast.Node) =>
          match node
          | let src_file: ast.SrcFile =>
            match src_file.docstring()
            | let docstrings: ast.NodeSeq[ast.Docstring] =>
              try
                return
                  h.assert_eq[USize](1, docstrings.size()) and
                  h.assert_eq[String]("This is a doc string\n",
                    docstrings(0)?.value())
              end
            end
          end
          false
        })
    ])
