use "pony_test"

use ast = "../ast"
use json = "../json"

primitive _TestAstParseNode
  fun apply(test: PonyTest) =>
    test(_TestAstParseNodeAnnotation)

class iso _TestAstParseNodeAnnotation is UnitTest
  fun name(): String => "ast/parse_node/annotation"
  fun exclusion_group(): String => "ast/parse_node"

  fun apply(h: TestHelper) =>
    let src =
      """
        {
          "name": "Annotation",
          "src_info": {
            "line": 4,
            "column": 8,
            "next_line": 4,
            "next_column": 13
          },
          "doc_strings": [],
          "pre_trivia": [],
          "post_trivia": [ 3 ],
          "identifiers": [ 1 ],
          "children": [
            { "name": "Token", "string": "/" },
            { "name": "Identifier", "string": "foo" },
            { "name": "Token", "string": "/" },
            { "name": "Trivia", "kind": "WhiteSpaceTrivia", "string": " "}
          ]
        }
      """
    match json.Parse(src)
    | let obj: json.Object =>
      match ast.ParseNode(name(), obj)
      | let ann: ast.NodeWith[ast.Annotation] =>
        h.assert_is[(USize | None)](4, ann.src_info().line, "line")
        h.assert_is[(USize | None)](8, ann.src_info().column, "column")
        h.assert_eq[USize](1, ann.post_trivia().size(), "post_trivia.size()")
        match try ann.post_trivia()(0)? end
        | let t: ast.Node =>
          h.assert_eq[String]("Trivia", t.name())
        else
          h.fail("post_trivia(0) is not a Trivia")
        end
        h.assert_eq[USize](1, ann.data().identifiers.size())
        match try ann.data().identifiers(0)? end
        | let t: ast.Node =>
          h.assert_eq[String]("Identifier", t.name())
        else
          h.fail("identifiers(0) is not an Identifier")
        end
        h.assert_eq[USize](4, ann.children().size())
      | let node: ast.Node =>
        h.fail("incorrect node " + node.name())
      | let err: String =>
        h.fail(err)
      end
    | let err: json.ParseError =>
      h.fail(err.message)
    else
      h.fail("source should be a json object")
    end
