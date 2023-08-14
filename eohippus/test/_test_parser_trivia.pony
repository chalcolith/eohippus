use "collections/persistent"
use "pony_test"

use ast = "../ast"
use json = "../json"
use parser = "../parser"

primitive _TestParserTrivia
  fun apply(test: PonyTest) =>
    test(_TestParserTriviaEOF)
    test(_TestParserTriviaEOL)
    test(_TestParserTriviaWS)
    test(_TestParserTriviaComment)
    test(_TestParserTriviaTrivia)

class iso _TestParserTriviaEOF is UnitTest
  fun name(): String => "parser/trivia/EOF"
  fun exclusion_group(): String => "parser/trivia"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.trivia.eof()

    let expected =
      """
        {
          "name": "Trivia",
          "kind": "EndOfFileTrivia"
        }
      """

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, "", expected)
        _Assert.test_match(h, rule, setup.data, " ", None) ])

class iso _TestParserTriviaEOL is UnitTest
  fun name(): String => "parser/trivia/EOL"
  fun exclusion_group(): String => "parser/trivia"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.trivia.eol()

    let expected =
      """
        {
          "name": "Trivia",
          "kind": "EndOfLineTrivia"
        }
      """

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, "\n", expected)
        _Assert.test_match(h, rule, setup.data, "\r\n", expected)
        _Assert.test_match(h, rule, setup.data, "\r", expected)
        _Assert.test_match(h, rule, setup.data, " ", None) ])

class _TestParserTriviaWS is UnitTest
  fun name(): String => "parser/trivia/WS"
  fun exclusion_group(): String => "parser/trivia"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.trivia.ws()

    let expected =
      """
        {
          "name": "Trivia",
          "kind": "WhiteSpaceTrivia"
        }
      """

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, " ", expected)
        _Assert.test_match(h, rule, setup.data, "\t", expected)
        _Assert.test_match(h, rule, setup.data, "", None) ])

class _TestParserTriviaComment is UnitTest
  fun name(): String => "parser/trivia/Comment"
  fun exclusion_group(): String => "parser/trivia"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.trivia.comment()

    let expected_1 =
      """
        {
          "name": "Trivia",
          "kind": "LineCommentTrivia"
        }
      """

    let expected_2 =
      """
        {
          "name": "Trivia",
          "kind": "NestedCommentTrivia"
        }
      """

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, "// foo\n", expected_1)
        _Assert.test_match(h, rule, setup.data, "// foo", expected_1)
        _Assert.test_match(h, rule, setup.data, "/* foo */", expected_2)
        _Assert.test_match(h, rule, setup.data, "/* foo", None)
        _Assert.test_match(h, rule, setup.data, "foo", None) ])

class iso _TestParserTriviaTrivia is UnitTest
  fun name(): String => "parser/trivia/Trivia"
  fun exclusion_group(): String => "parser/trivia"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.trivia.trivia()

    let assert_all_trivia =
      {(r: parser.Success, v: ast.NodeSeq): (Bool, String) =>
        if v.size() == 0 then
          return (false, "expected at least one trivia node")
        end
        for n in v.values() do
          match n
          | let t: ast.NodeWith[ast.Trivia] =>
            None
          else
            return (false, "value is not a trivia node")
          end
        end
        (true, "") }

    _Assert.test_all(
      h,
      [ _Assert.test_with(
        h, rule, setup.data, " /* c1 */\t// c2\n ", assert_all_trivia) ])
