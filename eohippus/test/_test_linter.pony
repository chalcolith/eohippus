use "pony_test"

use ast = "../ast"
use json = "../json"
use linter = "../linter"
use parser = "../parser"

primitive _TestLinter
  fun apply(test: PonyTest) =>
    test(_TestLinterAnalyzeTrimTrailingWhitespace)
    test(_TestLinterFixTrimTrailingWhitespace)

class iso _TestLinterAnalyzeTrimTrailingWhitespace is UnitTest
  fun name(): String => "linter/analyze/trim_trailing_whitespace"
  fun exclusion_group(): String => "linter/analyze"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let source =
      recover val
        [ " class A  \n  new create() =>\t\n    None " ]
      end

    let notify =
      object tag is linter.LinterNotify
        be lint_completed(
          lint: linter.Linter,
          task_id: USize,
          tree: ast.Node,
          issues: ReadSeq[linter.Issue] val,
          errors: ReadSeq[ast.TraverseError] val)
        =>
          h.assert_eq[USize](0, errors.size(), "should be 0 errors")
          h.assert_eq[USize](3, issues.size(), "should be 3 issues")

          var i: USize = 0
          while i < issues.size() do
            try
              let issue = issues(i)?
              h.assert_eq[String](
                linter.ConfigKey.trim_trailing_whitespace(),
                issue.rule.name(),
                "incorrect issue " + issue.rule.name())
            else
              h.fail("issue " + i.string() + " errored")
              break
            end
            i = i + 1
          end

          h.complete(true)

        be linter_failed(task_id: USize, message: String) =>
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
            (let root, _, _) = ast.SyntaxTree.add_line_info(v(0)?)
            let sf = root as ast.NodeWith[ast.SrcFile]
            let lint = linter.Linter(linter.EditorConfig.default(), notify)
            lint.lint(0, sf)
          else
            h.fail("result value was not a NodeWith[SrcFile]")
            h.complete(false)
          end
        | let failure: parser.Failure =>
          h.fail(failure.get_message())
          h.complete(false)
        end
      })
    h.long_test(10_000_000_000)

class iso _TestLinterFixTrimTrailingWhitespace is UnitTest
  fun name(): String => "linter/fix/trim_trailing_whitespace"
  fun exclusion_group(): String => "linter/fix"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let source =
      recover val
        // 0  1          2                    3            (lines)
        // 1         2                    3           4    (issues)
        [ " \nclass A  \n  new create() =>\t\n    None " ]
      end

    let expected_json =
      recover val
        match json.Parse(
          """
            {
              "name": "SrcFile",
              "src_info": {
                "line": 0,
                "column": 0
              },
              "locator": "linter/fix/trim_trailing_whitespace",
              "type_defs": [
                1
              ],
              "pre_trivia": [
                0
              ],
              "post_trivia": [
                2
              ],
              "children": [
                {
                  "name": "Trivia",
                  "src_info": {
                    "line": 0,
                    "column": 0
                  },
                  "kind": "EndOfLineTrivia",
                  "string": "\n"
                },
                {
                  "name": "TypedefClass",
                  "src_info": {
                    "line": 1,
                    "column": 0
                  },
                  "kind": 0,
                  "identifier": 1,
                  "members": 2,
                  "children": [
                    {
                      "name": "Keyword",
                      "src_info": {
                        "line": 1,
                        "column": 0
                      },
                      "string": "class",
                      "post_trivia": [
                        1
                      ],
                      "children": [
                        {
                          "name": "Span",
                          "src_info": {
                            "line": 1,
                            "column": 0
                          }
                        },
                        {
                          "name": "Trivia",
                          "src_info": {
                            "line": 1,
                            "column": 5
                          },
                          "kind": "WhiteSpaceTrivia",
                          "string": " "
                        }
                      ]
                    },
                    {
                      "name": "Identifier",
                      "src_info": {
                        "line": 1,
                        "column": 6
                      },
                      "string": "A",
                      "post_trivia": [
                        1,
                        2
                      ],
                      "children": [
                        {
                          "name": "Span",
                          "src_info": {
                            "line": 1,
                            "column": 6
                          }
                        },
                        {
                          "name": "Trivia",
                          "src_info": {
                            "line": 1,
                            "column": 7
                          },
                          "kind": "EndOfLineTrivia",
                          "string": "\n"
                        },
                        {
                          "name": "Trivia",
                          "src_info": {
                            "line": 2,
                            "column": 0
                          },
                          "kind": "WhiteSpaceTrivia",
                          "string": "  "
                        }
                      ]
                    },
                    {
                      "name": "TypedefMembers",
                      "src_info": {
                        "line": 2,
                        "column": 2
                      },
                      "methods": [
                        0
                      ],
                      "children": [
                        {
                          "name": "TypedefMethod",
                          "src_info": {
                            "line": 2,
                            "column": 2
                          },
                          "kind": 0,
                          "identifier": 1,
                          "body": 5,
                          "children": [
                            {
                              "name": "Keyword",
                              "src_info": {
                                "line": 2,
                                "column": 2
                              },
                              "string": "new",
                              "post_trivia": [
                                1
                              ],
                              "children": [
                                {
                                  "name": "Span",
                                  "src_info": {
                                    "line": 2,
                                    "column": 2
                                  }
                                },
                                {
                                  "name": "Trivia",
                                  "src_info": {
                                    "line": 2,
                                    "column": 5
                                  },
                                  "kind": "WhiteSpaceTrivia",
                                  "string": " "
                                }
                              ]
                            },
                            {
                              "name": "Identifier",
                              "src_info": {
                                "line": 2,
                                "column": 6
                              },
                              "string": "create",
                              "children": [
                                {
                                  "name": "Span",
                                  "src_info": {
                                    "line": 2,
                                    "column": 6
                                  }
                                }
                              ]
                            },
                            {
                              "name": "Token",
                              "src_info": {
                                "line": 2,
                                "column": 12
                              },
                              "string": "(",
                              "children": [
                                {
                                  "name": "Span",
                                  "src_info": {
                                    "line": 2,
                                    "column": 12
                                  }
                                }
                              ]
                            },
                            {
                              "name": "Token",
                              "src_info": {
                                "line": 2,
                                "column": 13
                              },
                              "string": ")",
                              "post_trivia": [
                                1
                              ],
                              "children": [
                                {
                                  "name": "Span",
                                  "src_info": {
                                    "line": 2,
                                    "column": 13
                                  }
                                },
                                {
                                  "name": "Trivia",
                                  "src_info": {
                                    "line": 2,
                                    "column": 14
                                  },
                                  "kind": "WhiteSpaceTrivia",
                                  "string": " "
                                }
                              ]
                            },
                            {
                              "name": "Token",
                              "src_info": {
                                "line": 2,
                                "column": 15
                              },
                              "string": "=>",
                              "post_trivia": [
                                1,
                                2
                              ],
                              "children": [
                                {
                                  "name": "Span",
                                  "src_info": {
                                    "line": 2,
                                    "column": 15
                                  }
                                },
                                {
                                  "name": "Trivia",
                                  "src_info": {
                                    "line": 2,
                                    "column": 17
                                  },
                                  "kind": "EndOfLineTrivia",
                                  "string": "\n"
                                },
                                {
                                  "name": "Trivia",
                                  "src_info": {
                                    "line": 3,
                                    "column": 0
                                  },
                                  "kind": "WhiteSpaceTrivia",
                                  "string": "    "
                                }
                              ]
                            },
                            {
                              "name": "ExpAtom",
                              "src_info": {
                                "line": 3,
                                "column": 4
                              },
                              "body": 0,
                              "children": [
                                {
                                  "name": "Identifier",
                                  "src_info": {
                                    "line": 3,
                                    "column": 4
                                  },
                                  "string": "None",
                                  "children": [
                                    {
                                      "name": "Span",
                                      "src_info": {
                                        "line": 3,
                                        "column": 4
                                      }
                                    }
                                  ]
                                }
                              ]
                            }
                          ]
                        }
                      ]
                    }
                  ]
                },
                {
                  "name": "Trivia",
                  "src_info": {
                    "line": 3,
                    "column": 8
                  },
                  "kind": "EndOfFileTrivia",
                  "string": ""
                }
              ]
            }
          """)
        | let item: json.Item =>
          item
        | let parse_error: json.ParseError =>
          h.fail(parse_error.message)
          h.complete(false)
          return
        end
      end

    let notify =
      object tag is linter.LinterNotify
        be lint_completed(
          lint: linter.Linter,
          task_id: USize,
          tree: ast.Node,
          issues: ReadSeq[linter.Issue] val,
          errors: ReadSeq[ast.TraverseError] val)
        =>
          h.log("ORIGINAL:\n" + tree.get_json().string())

          if not h.assert_eq[USize](4, issues.size(), "should be 4 issues") then
            h.complete(false)
          else
            lint.fix(0, tree, issues)
          end

        be fix_completed(
          lint: linter.Linter,
          task_id: USize,
          tree: ast.Node,
          issues: ReadSeq[linter.Issue] val,
          errors: ReadSeq[ast.TraverseError] val)
        =>
          h.assert_eq[USize](0, errors.size(), "should be 0 errors")
          for (_, msg) in errors.values() do
            h.log("ERROR: " + msg)
          end
          h.assert_eq[USize](0, issues.size(), "should be 0 unfixed issues")

          let actual_json = tree.get_json()
          (let sub, let msg) = json.Subsumes(expected_json, actual_json)
          if not sub then
            h.log("EXPECTED:\n" + expected_json.string())
            h.log("ACTUAL:\n" + actual_json.string())
          end

          h.assert_true(sub, msg)
          h.complete(true)

        be linter_failed(task_id: USize, message: String) =>
          h.fail(message)
          h.complete(false)
      end

    let lint = linter.Linter(linter.EditorConfig.default(), notify)
    let parse = parser.Parser(source)
    parse.parse(
      setup.builder.src_file.src_file,
      setup.data,
      {(r: (parser.Success | parser.Failure), v: ast.NodeSeq) =>
        match r
        | let success: parser.Success =>
          try
            (let root, _, _) = ast.SyntaxTree.add_line_info(v(0)?)
            let sf = root as ast.NodeWith[ast.SrcFile]
            lint.lint(0, sf)
          else
            h.fail("result value was not a NodeWith[SrcFile]")
            h.complete(false)
          end
        | let failure: parser.Failure =>
          h.fail(failure.get_message())
          h.complete(false)
        end
      })
    h.long_test(10_000_000_000)
