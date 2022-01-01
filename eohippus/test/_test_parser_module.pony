use "ponytest"

use ast = "../ast"
use parser = "../parser"
use ".."

primitive _TestParserModule
  fun apply(test: PonyTest) =>
    test(_TestParserModuleTriviaDocstring)

class iso _TestParserModuleTriviaDocstring is UnitTest
  fun name(): String => "parser/module/Module/trivia+docstring"
  fun exclusion_group(): String => "parser/module"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.module()

    let code = "\n // trivia!\n \"\"\"\n This is a doc string\n \"\"\""
    let len = code.size()

    let src1 = setup.src(code)
    let loc1 = parser.Loc(src1)
    let inf1 = ast.SrcInfo(setup.data.locator(), loc1, loc1 + len)

    _Assert.test_all(h, [
      _Assert.test_match(h, rule, src1, 0, setup.data, true, len, None, None,
        {(node: ast.Node) =>
          match node
          | let module: ast.Module =>
            match module.docstring()
            | let docstring: ast.Docstring =>
              return h.assert_eq[String]("This is a doc string\n",
                docstring.value())
            end
          end
          false
        })
    ])
