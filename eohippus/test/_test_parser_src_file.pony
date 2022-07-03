use "itertools"
use "pony_test"

use ast = "../ast"
use parser = "../parser"
use ".."

primitive _TestParserSrcFile
  fun apply(test: PonyTest) =>
    test(_TestParserSrcFileTriviaDocstring)
    test(_TestParserSrcFileUsing)
    test(_TestParserSrcFileUsingErrorSection)

class iso _TestParserSrcFileTriviaDocstring is UnitTest
  fun name(): String => "parser/src_file/SrcFile/Trivia+Docstring"
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

class iso _TestParserSrcFileUsing is UnitTest
  fun name(): String => "parser/src_file/SrcFile/Using"
  fun exclusion_group(): String => "parser/src_file"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.src_file()

    let code = "use \"foo\"\nuse baz = \"bar\""
    let len = code.size()

    let src1 = setup.src(code)
    let loc1 = parser.Loc(src1)
    let inf1 = ast.SrcInfo(setup.data.locator(), loc1, loc1 + len)

    _Assert.test_all(h, [
      _Assert.test_match(h, rule, src1, 0, setup.data, true, len, None, None,
        {(node: ast.Node) =>
          try
            let using1 = (node as ast.SrcFile).usings()(0)? as ast.UsingPony
            let using2 = (node as ast.SrcFile).usings()(1)? as ast.UsingPony
            let name = (using2.identifier() as ast.Identifier).name()

            (using1.path().value() == "foo") and
            (using2.path().value() == "bar") and
            (name == "baz")
          else
            false
          end
        })
    ])

class iso _TestParserSrcFileUsingErrorSection is UnitTest
  fun name(): String => "parser/src_file/SrcFile/Using+ErrorSection"
  fun exclusion_group(): String => "parser/src_file"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.src_file()

    let code =
      """
        // comment
        use "bar"

        gousbnfg

        use "baz"
      """
    let len = code.size()

    let src1 = setup.src(code)
    let loc1 = parser.Loc(src1)
    let inf1 = ast.SrcInfo(setup.data.locator(), loc1, loc1 + len)

    _Assert.test_all(h, [
      _Assert.test_match(h, rule, src1, 0, setup.data, true, len, None, None,
        {(node: ast.Node) =>
          try
            let src_file = node as ast.SrcFile
            let usings = src_file.usings()

            (h.assert_eq[USize](2, usings.size())) and
            (Iter[ast.Node](src_file.children().values())
              .filter_map[ast.ErrorSection](
                {(child) => try child as ast.ErrorSection end})
              .count() == 1)
          else
            false
          end
        })
    ])
