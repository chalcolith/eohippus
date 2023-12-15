use "debug"
use "pony_test"

use ast = "../ast"
use parser = "../parser"

primitive _TestSyntaxTree
  fun apply(test: PonyTest) =>
    test(_TestSyntaxTreeLineBeginnings)

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
              let root = v(0)?
              let json = root.get_json()
              Debug.out(json)

              let st = ast.SyntaxTree(root)
              succeeded = succeeded and
                h.assert_eq[USize](
                  4, st.line_beginnings.size(), "bad # of lines")

              var pos = st.line_beginnings(0)?.index()
              succeeded = succeeded and
                h.assert_eq[USize](0, pos, "wrong pos for line 1")

              pos = st.line_beginnings(1)?.index()
              succeeded = succeeded and
                h.assert_eq[USize](8, pos, "wrong pos for line 2")

              pos = st.line_beginnings(2)?.index()
              succeeded = succeeded and
                h.assert_eq[USize](20, pos, "wrong pos for line 3")
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
