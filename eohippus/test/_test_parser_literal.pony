use "collections/persistent"
use "ponytest"

use "kiuatan"

use "../ast"
use "../parser"
use "../types"

class _TestLiteralSetup
  let context: ParserContext[U8]
  let builder: ParserBuilder[U8]
  let data: ParserData[U8]

  new create(name: String) =>
    context = ParserContext[U8](recover Array[AstPackage[U8] val] end)
    builder = ParserBuilder[U8](context)
    data = ParserData[U8](name)

  fun src(str: String): List[ReadSeq[U8] val] =>
    Lists[ReadSeq[U8] val]([ str ])

class iso _TestParserLiteralBool is UnitTest
  fun name(): String => "parser/literal/Bool"
  fun exclusion_group(): String => "parser/literal"

  fun apply(h: TestHelper) =>
    let setup = _TestLiteralSetup(name())
    let rule = setup.builder.literal_bool()

    let src1 = setup.src("true")
    let loc1 = Loc[U8](src1)
    let inf1 = SrcInfo[U8](setup.data.locator(), loc1, loc1 + 4)
    let exp1 = recover AstLiteralBool[U8](setup.context, inf1, true) end

    let src2 = setup.src("false")
    let loc2 = Loc[U8](src2)
    let inf2 = SrcInfo[U8](setup.data.locator(), loc2, loc2 + 5)
    let exp2 = recover AstLiteralBool[U8](setup.context, inf2, false) end

    let src3 = setup.src("foo")
    let src4 = setup.src("")

    _Assert[U8].test_all(h, [
      _Assert[U8].test_match(h, rule, src1, 0, setup.data, true, 4, exp1)
      _Assert[U8].test_match(h, rule, src1, 1, setup.data, false)
      _Assert[U8].test_match(h, rule, src2, 0, setup.data, true, 5, exp2)
      _Assert[U8].test_match(h, rule, src3, 0, setup.data, false)
      _Assert[U8].test_match(h, rule, src4, 0, setup.data, false)
    ])
