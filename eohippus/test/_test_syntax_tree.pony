use "pony_test"

use ast = "../ast"
use json = "../json"
use parser = "../parser"

primitive _TestSyntaxTree
  fun apply(test: PonyTest) =>
    test(_TestSyntaxTreeLineBeginnings)
    test(_TestSyntaxTreeLineNumbers)

class iso _TestSyntaxTreeLineBeginnings is UnitTest
  fun name(): String => "parser/syntax_tree/line_beginnings"
  fun exclusion_group(): String => "parser/syntax_tree"

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

class iso _TestSyntaxTreeLineNumbers is UnitTest
  fun name(): String => "parser/syntax_tree/line_numbers"
  fun exclusion_group(): String => "parser/syntax_tree"

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
            h.assert_eq[USize](
              0, st.lines_and_columns(src_file)?._1, "starting line")
            h.assert_eq[USize](
              0, st.lines_and_columns(src_file)?._2, "starting col")
            h.assert_eq[USize](2, src_file.data().type_defs.size(), "# types")

            let a = src_file.data().type_defs(0)?
            h.assert_eq[USize](0, st.lines_and_columns(a)?._1, "A line")
            h.assert_eq[USize](0, st.lines_and_columns(a)?._2, "A col")

            let c = a.data() as ast.TypedefClass
            let m = c.members
              as ast.NodeWith[ast.TypedefMembers]
            let nc = m.data().methods(0)?
            let nc_id = nc.data().identifier
            h.assert_eq[USize](1, st.lines_and_columns(nc_id)?._1, "nc line")
            h.assert_eq[USize](6, st.lines_and_columns(nc_id)?._2, "nc col")

            let b = src_file.data().type_defs(1)?
            let b_id = (b.data() as ast.TypedefClass).identifier
            h.assert_eq[USize](2, st.lines_and_columns(b_id)?._1, "B line")
            h.assert_eq[USize](10, st.lines_and_columns(b_id)?._2, "B col")
          else
            h.fail("error in parse tree")
          end
        | let failure: parser.Failure =>
          h.fail(failure.get_message())
        end

        h.complete(true)
      })

    h.long_test(2_000_000_000)
