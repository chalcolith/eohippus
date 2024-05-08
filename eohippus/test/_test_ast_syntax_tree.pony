use "pony_test"

use ast = "../ast"
use json = "../json"
use parser = "../parser"

primitive _TestAstSyntaxTree
  fun apply(test: PonyTest) =>
    test(_TestAstSyntaxTreeLineBeginnings)
    test(_TestAstSyntaxTreeLineNumbers)

class iso _TestAstSyntaxTreeLineBeginnings is UnitTest
  fun name(): String => "ast/syntax_tree/line_beginnings"
  fun exclusion_group(): String => "ast/syntax_tree"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let source = recover val [ "class A\ninterface B\ntrait C\n" ] end

    let parse = parser.Parser(source)
    parse.parse(
      setup.builder.src_file.src_file,
      setup.data,
      { (r: (parser.Success | parser.Failure), v: ast.NodeSeq) =>
        var succeeded = true
        match r
        | let success: parser.Success =>
          if
            h.assert_eq[USize](1, v.size(), "should have one result value")
          then
            try
              let st = ast.SyntaxTree(v(0)?)

              succeeded = succeeded and
                h.assert_eq[USize](
                  4, st.line_beginnings.size(), "bad # of lines")

              var pos = st.line_beginnings(0)?.index()
              succeeded = succeeded and
                h.assert_eq[USize](0, pos, "wrong pos for line 0")

              pos = st.line_beginnings(1)?.index()
              succeeded = succeeded and
                h.assert_eq[USize](8, pos, "wrong pos for line 1")

              pos = st.line_beginnings(2)?.index()
              succeeded = succeeded and
                h.assert_eq[USize](20, pos, "wrong pos for line 2")
            else
              succeeded = false
              h.fail("array index out of bounds")
            end
          else
            succeeded = false
          end
        | let failure: parser.Failure =>
          succeeded = false
          h.fail(failure.get_message())
        end
        h.complete(succeeded)
      })
    h.long_test(2_000_000_000)

class iso _TestAstSyntaxTreeLineNumbers is UnitTest
  fun name(): String => "ast/syntax_tree/line_numbers"
  fun exclusion_group(): String => "ast/syntax_tree"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let source =
      """
        class A
          new create() => None
        interface B
      """

    let parse = parser.Parser([ source ])
    parse.parse(
      setup.builder.src_file.src_file,
      setup.data,
      { (r: (parser.Success | parser.Failure), v: ast.NodeSeq) =>
        match r
        | let success: parser.Success =>
          try
            let st = ast.SyntaxTree(v(0)?)

            let src_file = st.root as ast.NodeWith[ast.SrcFile]
            match (src_file.src_info().line, src_file.src_info().column)
            | (let line: USize, let column: USize) =>
              h.assert_eq[USize](0, line, "starting line")
              h.assert_eq[USize](0, column, "starting column")
            else
              h.fail("no line or column info for src_file")
            end
            h.assert_eq[USize](2, src_file.data().type_defs.size(), "# types")

            let a = src_file.data().type_defs(0)?
            match (a.src_info().line, a.src_info().column)
            | (let line: USize, let column: USize) =>
              h.assert_eq[USize](0, line, "A line")
              h.assert_eq[USize](0, column, "A column")
            else
              h.fail("no line or column info for a")
            end

            let c = a.data() as ast.TypedefClass
            let m = c.members
              as ast.NodeWith[ast.TypedefMembers]
            let nc = m.data().methods(0)?
            let nc_id = nc.data().identifier
            match (nc_id.src_info().line, nc_id.src_info().column)
            | (let line: USize, let column: USize) =>
              h.assert_eq[USize](1, line, "nc_id line")
              h.assert_eq[USize](6, column, "nc_id column")
            else
              h.fail("no line or column info for nc_id")
            end

            let b = src_file.data().type_defs(1)?
            let b_id = (b.data() as ast.TypedefClass).identifier
            match (b_id.src_info().line, b_id.src_info().column)
            | (let line: USize, let column: USize) =>
              h.assert_eq[USize](2, line, "b_id line")
              h.assert_eq[USize](10, column, "b_id column")
            else
              h.fail("no line or column info in b_id")
            end
          else
            h.fail("error in parse tree")
          end
        | let failure: parser.Failure =>
          h.fail(failure.get_message())
        end

        h.complete(true)
      })

    h.long_test(2_000_000_000)
