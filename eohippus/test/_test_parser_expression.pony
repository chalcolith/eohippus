use "pony_test"

use ast = "../ast"
use parser = "../parser"
use ".."

primitive _TestParserExpression
  fun apply(test: PonyTest) =>
    test(_TestParserExpressionIdentifier)
    test(_TestParserExpressionAnnotation)

class iso _TestParserExpressionIdentifier is UnitTest
  fun name(): String => "parser/expression/Identifier"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.identifier()

    let src1 = setup.src("a1_'")
    let loc1 = parser.Loc(src1)
    let inf1 = ast.SrcInfo(setup.data.locator(), loc1, loc1 + 4)
    let exp1 = ast.Identifier(inf1)

    _Assert.test_all(h, [
      _Assert.test_match(h, rule, src1, 0, setup.data, true, 4, exp1)
      _Assert.test_match(h, rule, src1, 4, setup.data, false)
    ])

class iso _TestParserExpressionAnnotation is UnitTest
  fun name(): String => "parser/expression/Annotation"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.annotation()

    let src1 = setup.src("\\ one,two, three \\")
    let loc1 = parser.Loc(src1)
    let inf1 = ast.SrcInfo(setup.data.locator(), loc1, loc1 + 18)

    _Assert.test_all(h, [
      _Assert.test_match(h, rule, src1, 0, setup.data, true, 18, None, None,
        {(node) =>
          try
            let ann = node as ast.Annotation
            let id0 = ann.identifiers()(0)?.name()
            let id1 = ann.identifiers()(1)?.name()
            let id2 = ann.identifiers()(2)?.name()

            h.assert_eq[String]("one", id0) and
              h.assert_eq[String]("two", id1) and
              h.assert_eq[String]("three", id2)
          else
            false
          end
        })
      _Assert.test_match(h, rule, src1, 18, setup.data, false)
    ])
