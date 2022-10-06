use "pony_test"

use ast = "../ast"
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
    let rule = setup.builder.typedef.td_primitive()

    let code = "  primitive FooBar\n\"\"\"docs\"\"\"  "
    let len = code.size()

    let src1 = setup.src(code)
    let loc1 = parser.Loc(src1)
    let inf1 = ast.SrcInfo(setup.data.locator(), loc1, loc1 + len)

    _Assert.test_all(h, [
      _Assert.test_match(h, rule, src1, 0, setup.data, true, len, None, None,
        {(node: ast.Node) =>
          match node
          | let prim: ast.TypedefPrimitive =>
            h.assert_eq[String]("FooBar", prim.identifier().name()) and
            h.assert_eq[USize](1, prim.docstring().size()) and
            h.assert_eq[String]("docs",
              try
                prim.docstring()(0)?.value()
              else
                ""
              end)
          else
            false
          end
        })
    ])
