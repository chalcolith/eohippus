use "collections/persistent"
use "ponytest"

use ast = "../ast"
use parser = "../parser"

class iso _TestParserLiteralBool is UnitTest
  fun name(): String => "parser/literal/Bool"
  fun exclusion_group(): String => "parser/literal"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.literal_bool()

    let src1 = setup.src("true")
    let loc1 = parser.Loc(src1)
    let inf1 = ast.SrcInfo(setup.data.locator(), loc1, loc1 + 4)
    let exp1 = recover ast.LiteralBool(setup.context, inf1, true) end

    let src2 = setup.src("false")
    let loc2 = parser.Loc(src2)
    let inf2 = ast.SrcInfo(setup.data.locator(), loc2, loc2 + 5)
    let exp2 = recover ast.LiteralBool(setup.context, inf2, false) end

    let src3 = setup.src("foo")
    let src4 = setup.src("")

    _Assert.test_all(h, [
      _Assert.test_match(h, rule, src1, 0, setup.data, true, 4, exp1)
      _Assert.test_match(h, rule, src1, 1, setup.data, false)
      _Assert.test_match(h, rule, src2, 0, setup.data, true, 5, exp2)
      _Assert.test_match(h, rule, src3, 0, setup.data, false)
      _Assert.test_match(h, rule, src4, 0, setup.data, false)
    ])
