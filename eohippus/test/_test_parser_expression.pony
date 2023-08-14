use "pony_test"

use ast = "../ast"
use json = "../json"
use parser = "../parser"
use ".."

primitive _TestParserExpression
  fun apply(test: PonyTest) =>
    test(_TestParserExpressionIdentifier)
    test(_TestParserExpressionIf)
    test(_TestParserExpressionIfDef)

class iso _TestParserExpressionIdentifier is UnitTest
  fun name(): String => "parser/expression/Identifier"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.token.identifier()

    let expected =
      """
        {
          "name": "Identifier",
          "string": "a1_'"
        }
      """

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, "a1_'", expected)
        _Assert.test_match(h, rule, setup.data, "1abc", None)
        _Assert.test_match(h, rule, setup.data, "", None) ])

class iso _TestParserExpressionIf is UnitTest
  fun name(): String => "parser/expression/If"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item()
    h.fail()

    // let src = "if true then foo elseif false then bar else baz end"

    // let src1 = setup.src(src)
    // let loc1 = parser.Loc(src1)
    // let inf1 = ast.SrcInfo(setup.data.locator(), loc1, loc1 + src.size())

    // _Assert.test_all(h, [
    //   _Assert.test_match(h, rule, src1, 0, setup.data, true, src.size(),
    //     None, None, {(node: ast.Node) =>
    //       let str = node.string()

    //       let if_exp =
    //         try
    //           node as ast.ExpIf
    //         else
    //           h.fail("Value is not an If node")
    //           return false
    //         end

    //       let true_lit =
    //         try
    //           (if_exp.conditions()(0)?.if_true() as ast.NodeWithChildren)
    //             .children()(0)? as ast.LiteralBool
    //         else
    //           h.fail("First condition is not a LiteralBool")
    //           return false
    //         end
    //       h.assert_eq[Bool](true, true_lit.value(), "Condition is not true")

    //       let foo_id =
    //         try
    //           (if_exp.conditions()(0)?.then_block() as ast.NodeWithChildren)
    //             .children()(0)? as ast.Identifier
    //         else
    //           h.fail("First then block exp is not an Identifier")
    //           return false
    //         end
    //       h.assert_eq[String]("foo", foo_id.name(),
    //         "First identifier is not 'foo'")

    //       let false_lit =
    //         try
    //           (if_exp.conditions()(1)?.if_true() as ast.NodeWithChildren)
    //             .children()(0)? as ast.LiteralBool
    //         else
    //           h.fail("Second condition is not a LiteralBool")
    //           return false
    //         end
    //       h.assert_eq[Bool](false, false_lit.value(), "Condition is not false")

    //       let bar_id =
    //         try
    //           (if_exp.conditions()(1)?.then_block() as ast.NodeWithChildren)
    //             .children()(0)? as ast.Identifier
    //         else
    //           h.fail("Second then block exp is not an Identifier")
    //           return false
    //         end
    //       h.assert_eq[String]("bar", bar_id.name(),
    //         "Second identifier is not 'bar'")

    //       let baz_id =
    //         try
    //           (if_exp.else_block() as ast.NodeWithChildren)
    //             .children()(0)? as ast.Identifier
    //         else
    //           h.fail("Else block exp is not an identifier")
    //           return false
    //         end
    //       h.assert_eq[String]("baz", baz_id.name(),
    //         "Third identifier is not 'baz'")

    //       true
    //     })
    // ])

class iso _TestParserExpressionIfDef is UnitTest
  fun name(): String => "parser/expression/IfDef"
  fun exclusion_group(): String => "parser/expression"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.item()
    h.fail()

    // let src = "ifdef windows then foo elseif unix then bar else baz end"

    // let src1 = setup.src(src)
    // let loc1 = parser.Loc(src1)
    // let inf1 = ast.SrcInfo(setup.data.locator(), loc1, loc1 + src.size())

    // _Assert.test_all(h, [
    //   _Assert.test_match(h, rule, src1, 0, setup.data, true, src.size(),
    //     None, None, {(node: ast.Node) =>
    //       let str = node.string()

    //       let if_exp =
    //         match node
    //         | let ifdef_node: ast.ExpIfDef =>
    //           ifdef_node
    //         | let error_node: ast.ErrorSection =>
    //           h.fail(error_node.message())
    //           return false
    //         else
    //           h.fail("Value is not an If node")
    //           return false
    //         end

    //       let windows_id =
    //         try
    //           (if_exp.conditions()(0)?.if_true() as ast.NodeWithChildren)
    //             .children()(0)? as ast.Identifier
    //         else
    //           h.fail("First condition is not an Identifier")
    //           return false
    //         end
    //       h.assert_eq[String]("windows", windows_id.name(),
    //         "Condition is not windows")

    //       let foo_id =
    //         try
    //           (if_exp.conditions()(0)?.then_block() as ast.NodeWithChildren)
    //             .children()(0)? as ast.Identifier
    //         else
    //           h.fail("First then block exp is not an Identifier")
    //           return false
    //         end
    //       h.assert_eq[String]("foo", foo_id.name(),
    //         "First identifier is not 'foo'")

    //       let unix_id =
    //         try
    //           (if_exp.conditions()(1)?.if_true() as ast.NodeWithChildren)
    //             .children()(0)? as ast.Identifier
    //         else
    //           h.fail("Second condition is not an Identifier")
    //           return false
    //         end
    //       h.assert_eq[String]("unix", unix_id.name(), "Condition is not unix")

    //       let bar_id =
    //         try
    //           (if_exp.conditions()(1)?.then_block() as ast.NodeWithChildren)
    //             .children()(0)? as ast.Identifier
    //         else
    //           h.fail("Second then block exp is not an Identifier")
    //           return false
    //         end
    //       h.assert_eq[String]("bar", bar_id.name(),
    //         "Second identifier is not 'bar'")

    //       let baz_id =
    //         try
    //           (if_exp.else_block() as ast.NodeWithChildren)
    //             .children()(0)? as ast.Identifier
    //         else
    //           h.fail("Else block exp is not an identifier")
    //           return false
    //         end
    //       h.assert_eq[String]("baz", baz_id.name(),
    //         "Third identifier is not 'baz'")

    //       true
    //     })
    // ])
