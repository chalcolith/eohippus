use "pony_test"

use ast = "../ast"
use lint = "../lint"
use parser = "../parser"

primitive _TestLinter
  fun apply(test: PonyTest) =>
    test(_TestLinterAnalyzeTrimTrailingWhitespace)

class iso _TestLinterAnalyzeTrimTrailingWhitespace is UnitTest
  fun name(): String => "linter/analyze/trim_trailing_whitespace"
  fun exclusion_group(): String => "linter/analyze"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let source =
      recover val
        [ " class A  \n  new create() =>\t\n    None " ]
      end

    let listener: lint.Listener val =
      object
        fun apply(
          tree: ast.SyntaxTree iso,
          issues: ReadSeq[lint.Issue] iso)
        =>
          h.assert_eq[USize](3, issues.size(), "should be 3 issues")

          var i: USize = 0
          while i < issues.size() do
            try
              let issue = issues(i)?
              h.assert_eq[String](
                lint.ConfigKey.trim_trailing_whitespace(),
                issue.rule.name(),
                "incorrect issue " + issue.rule.name())
            else
              h.fail("issue " + i.string() + " errored")
              break
            end
            i = i + 1
          end

          h.complete(true)

        fun reject(message: String) =>
          h.fail(message)
          h.complete(false)
      end

    let parse = parser.Parser(source)
    parse.parse(
      setup.builder.src_file.src_file,
      setup.data,
      { (r: (parser.Success | parser.Failure), v: ast.NodeSeq) =>
        match r
        | let success: parser.Success =>
          try
            let sf = v(0)? as ast.NodeWith[ast.SrcFile]

            let linter = lint.Linter(
              recover val
                lint.Config
                  .> update(lint.ConfigKey.trim_trailing_whitespace(), "true")
              end)
            linter.analyze(ast.SyntaxTree(sf), listener)
          else
            h.fail("value was not a SrcFile")
            h.complete(false)
          end
        | let failure: parser.Failure =>
          h.fail(failure.get_message())
          h.complete(false)
        end
      })
    h.long_test(2_000_000_000)
