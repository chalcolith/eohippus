use "itertools"
use "pony_test"

use ast = "../ast"
use json = "../json"
use parser = "../parser"
use ".."

primitive _TestParserSrcFile
  fun apply(test: PonyTest) =>
    test(_TestParserSrcFileStdlibEnv)
    test(_TestParserSrcFileTriviaDocstring)
    test(_TestParserSrcFileTypedefMultiple)
    test(_TestParserSrcFileTypedefSingle)
    test(_TestParserSrcFileUsingPony)
    test(_TestParserSrcFileUsingFfi)
    test(_TestParserSrcFileUsingErrorSection)

class iso _TestParserSrcFileTriviaDocstring is UnitTest
  fun name(): String => "parser/src_file/SrcFile/Trivia+Docstring"
  fun exclusion_group(): String => "parser/src_file"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.src_file.src_file

    let src = "\n // trivia!\n \"\"\"\n This is a doc string\n \"\"\" \t"
    let exp =
      """
        {
          "name": "SrcFile",
          "locator": "parser/src_file/SrcFile/Trivia+Docstring",
          "pre_trivia": [
            0,
            1,
            2,
            3,
            4
          ],
          "doc_strings": [
            5
          ],
          "post_trivia": [
            6
          ],
          "children": [
            {
              "name": "Trivia",
              "kind": "EndOfLineTrivia",
              "string": "\n"
            },
            {
              "name": "Trivia",
              "kind": "WhiteSpaceTrivia",
              "string": " "
            },
            {
              "name": "Trivia",
              "kind": "LineCommentTrivia",
              "string": "// trivia!"
            },
            {
              "name": "Trivia",
              "kind": "EndOfLineTrivia",
              "string": "\n"
            },
            {
              "name": "Trivia",
              "kind": "WhiteSpaceTrivia",
              "string": " "
            },
            {
              "name": "DocString",
              "string": 0,
              "children": [
                {
                  "name": "LiteralString",
                  "kind": "StringTripleQuote",
                  "value": "This is a doc string",
                  "post_trivia": [
                    6
                  ],
                  "children": [
                    {
                      "name": "Token",
                      "string": "\"\"\"",
                      "children": [
                        {
                          "name": "Span"
                        }
                      ]
                    },
                    {
                      "name": "Trivia",
                      "kind": "EndOfLineTrivia"
                    },
                    {
                      "name": "Span"
                    },
                    {
                      "name": "Trivia",
                      "kind": "EndOfLineTrivia"
                    },
                    {
                      "name": "Span"
                    },
                    {
                      "name": "Token",
                      "string": "\"\"\"",
                      "children": [
                        {
                          "name": "Span"
                        }
                      ]
                    },
                    {
                      "name": "Trivia",
                      "kind": "WhiteSpaceTrivia",
                      "string": " \t"
                    }
                  ]
                }
              ]
            },
            {
              "name": "Trivia",
              "kind": "EndOfFileTrivia",
              "string": ""
            }
          ]
        }
      """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])

class iso _TestParserSrcFileUsingPony is UnitTest
  fun name(): String => "parser/src_file/Using/Pony"
  fun exclusion_group(): String => "parser/src_file"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.src_file.src_file

    let src = " use \"foo\" if windows\nuse baz = \"bar\" if not osx"
    let exp =
      """
        {
          "name": "SrcFile",
          "locator": "parser/src_file/Using/Pony",
          "usings": [
            1,
            2
          ],
          "pre_trivia": [
            0
          ],
          "post_trivia": [
            3
          ],
          "children": [
            {
              "name": "Trivia",
              "kind": "WhiteSpaceTrivia",
              "string": " "
            },
            {
              "name": "UsingPony",
              "path": 1,
              "define": 3,
              "children": [
                {
                  "name": "Keyword",
                  "string": "use",
                  "post_trivia": [
                    1
                  ],
                  "children": [
                    {
                      "name": "Span"
                    },
                    {
                      "name": "Trivia",
                      "kind": "WhiteSpaceTrivia",
                      "string": " "
                    }
                  ]
                },
                {
                  "name": "LiteralString",
                  "kind": "StringLiteral",
                  "value": "foo",
                  "post_trivia": [
                    3
                  ],
                  "children": [
                    {
                      "name": "Token",
                      "string": "\"",
                      "children": [
                        {
                          "name": "Span"
                        }
                      ]
                    },
                    {
                      "name": "Span"
                    },
                    {
                      "name": "Token",
                      "string": "\"",
                      "children": [
                        {
                          "name": "Span"
                        }
                      ]
                    },
                    {
                      "name": "Trivia",
                      "kind": "WhiteSpaceTrivia",
                      "string": " "
                    }
                  ]
                },
                {
                  "name": "Keyword",
                  "string": "if",
                  "post_trivia": [
                    1
                  ],
                  "children": [
                    {
                      "name": "Span"
                    },
                    {
                      "name": "Trivia",
                      "kind": "WhiteSpaceTrivia",
                      "string": " "
                    }
                  ]
                },
                {
                  "name": "Identifier",
                  "string": "windows",
                  "post_trivia": [
                    1
                  ],
                  "children": [
                    {
                      "name": "Span"
                    },
                    {
                      "name": "Trivia",
                      "kind": "EndOfLineTrivia",
                      "string": "\n"
                    }
                  ]
                }
              ]
            },
            {
              "name": "UsingPony",
              "identifier": 1,
              "path": 3,
              "def_true": false,
              "define": 6,
              "children": [
                {
                  "name": "Keyword",
                  "string": "use",
                  "post_trivia": [
                    1
                  ],
                  "children": [
                    {
                      "name": "Span"
                    },
                    {
                      "name": "Trivia",
                      "kind": "WhiteSpaceTrivia",
                      "string": " "
                    }
                  ]
                },
                {
                  "name": "Identifier",
                  "string": "baz",
                  "post_trivia": [
                    1
                  ],
                  "children": [
                    {
                      "name": "Span"
                    },
                    {
                      "name": "Trivia",
                      "kind": "WhiteSpaceTrivia",
                      "string": " "
                    }
                  ]
                },
                {
                  "name": "Token",
                  "string": "=",
                  "post_trivia": [
                    1
                  ],
                  "children": [
                    {
                      "name": "Span"
                    },
                    {
                      "name": "Trivia",
                      "kind": "WhiteSpaceTrivia",
                      "string": " "
                    }
                  ]
                },
                {
                  "name": "LiteralString",
                  "kind": "StringLiteral",
                  "value": "bar",
                  "post_trivia": [
                    3
                  ],
                  "children": [
                    {
                      "name": "Token",
                      "string": "\"",
                      "children": [
                        {
                          "name": "Span"
                        }
                      ]
                    },
                    {
                      "name": "Span"
                    },
                    {
                      "name": "Token",
                      "string": "\"",
                      "children": [
                        {
                          "name": "Span"
                        }
                      ]
                    },
                    {
                      "name": "Trivia",
                      "kind": "WhiteSpaceTrivia",
                      "string": " "
                    }
                  ]
                },
                {
                  "name": "Keyword",
                  "string": "if",
                  "post_trivia": [
                    1
                  ],
                  "children": [
                    {
                      "name": "Span"
                    },
                    {
                      "name": "Trivia",
                      "kind": "WhiteSpaceTrivia",
                      "string": " "
                    }
                  ]
                },
                {
                  "name": "Keyword",
                  "string": "not",
                  "post_trivia": [
                    1
                  ],
                  "children": [
                    {
                      "name": "Span"
                    },
                    {
                      "name": "Trivia",
                      "kind": "WhiteSpaceTrivia",
                      "string": " "
                    }
                  ]
                },
                {
                  "name": "Identifier",
                  "string": "osx",
                  "children": [
                    {
                      "name": "Span"
                    }
                  ]
                }
              ]
            },
            {
              "name": "Trivia",
              "kind": "EndOfFileTrivia",
              "string": ""
            }
          ]
        }
      """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])

class iso _TestParserSrcFileUsingFfi is UnitTest
  fun name(): String => "parser/src_file/Using/FFI"
  fun exclusion_group(): String => "parser/src_file"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.src_file.src_file

    let src = " use a = @b[None](c: U8, ...) ? if not osx"
    let exp = """
      {
        "name": "SrcFile",
        "locator": "parser/src_file/Using/FFI",
        "usings": [
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
            "kind": "WhiteSpaceTrivia",
            "string": " "
          },
          {
            "name": "UsingFFI",
            "identifier": 1,
            "fun_name": 4,
            "type_args": 5,
            "params": 7,
            "varargs": true,
            "partial": true,
            "children": [
              {
                "name": "Keyword",
                "string": "use",
                "post_trivia": [
                  1
                ],
                "children": [
                  {
                    "name": "Span"
                  },
                  {
                    "name": "Trivia",
                    "kind": "WhiteSpaceTrivia",
                    "string": " "
                  }
                ]
              },
              {
                "name": "Identifier",
                "string": "a",
                "post_trivia": [
                  1
                ],
                "children": [
                  {
                    "name": "Span"
                  },
                  {
                    "name": "Trivia",
                    "kind": "WhiteSpaceTrivia",
                    "string": " "
                  }
                ]
              },
              {
                "name": "Token",
                "string": "=",
                "post_trivia": [
                  1
                ],
                "children": [
                  {
                    "name": "Span"
                  },
                  {
                    "name": "Trivia",
                    "kind": "WhiteSpaceTrivia",
                    "string": " "
                  }
                ]
              },
              {
                "name": "Token",
                "string": "@",
                "children": [
                  {
                    "name": "Span"
                  }
                ]
              },
              {
                "name": "Identifier",
                "string": "b",
                "children": [
                  {
                    "name": "Span"
                  }
                ]
              },
              {
                "name": "TypeArgs",
                "types": [
                  1
                ],
                "children": [
                  {
                    "name": "Token",
                    "string": "[",
                    "children": [
                      {
                        "name": "Span"
                      }
                    ]
                  },
                  {
                    "name": "TypeNominal",
                    "rhs": 0,
                    "children": [
                      {
                        "name": "Identifier",
                        "string": "None",
                        "children": [
                          {
                            "name": "Span"
                          }
                        ]
                      }
                    ]
                  },
                  {
                    "name": "Token",
                    "string": "]",
                    "children": [
                      {
                        "name": "Span"
                      }
                    ]
                  }
                ]
              },
              {
                "name": "Token",
                "string": "(",
                "children": [
                  {
                    "name": "Span"
                  }
                ]
              },
              {
                "name": "MethodParams",
                "params": [
                  0
                ],
                "children": [
                  {
                    "name": "MethodParam",
                    "identifier": 0,
                    "constraint": 2,
                    "children": [
                      {
                        "name": "Identifier",
                        "string": "c",
                        "children": [
                          {
                            "name": "Span"
                          }
                        ]
                      },
                      {
                        "name": "Token",
                        "string": ":",
                        "post_trivia": [
                          1
                        ],
                        "children": [
                          {
                            "name": "Span"
                          },
                          {
                            "name": "Trivia",
                            "kind": "WhiteSpaceTrivia",
                            "string": " "
                          }
                        ]
                      },
                      {
                        "name": "TypeNominal",
                        "rhs": 0,
                        "children": [
                          {
                            "name": "Identifier",
                            "string": "U8",
                            "children": [
                              {
                                "name": "Span"
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
                "name": "Token",
                "string": ","
              },
              {
                "name": "Token",
                "string": "..."
              },
              {
                "name": "Token",
                "string": ")",
                "post_trivia": [
                  1
                ],
                "children": [
                  {
                    "name": "Span"
                  },
                  {
                    "name": "Trivia",
                    "kind": "WhiteSpaceTrivia",
                    "string": " "
                  }
                ]
              },
              {
                "name": "Token",
                "string": "?",
                "post_trivia": [
                  1
                ],
                "children": [
                  {
                    "name": "Span"
                  },
                  {
                    "name": "Trivia",
                    "kind": "WhiteSpaceTrivia",
                    "string": " "
                  }
                ]
              }
            ]
          },
          {
            "name": "Trivia",
            "kind": "EndOfFileTrivia",
            "string": ""
          }
        ]
      }
    """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])

class iso _TestParserSrcFileUsingErrorSection is UnitTest
  fun name(): String => "parser/src_file/SrcFile/Using/error_section"
  fun exclusion_group(): String => "parser/src_file"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.src_file.src_file

    //         0           11         20  22      30  32  36       42
    let src = "// comment\nuse \"bar\"\n\ngousbnfg\n\nuse \"baz\"\n"
    let exp =
      """
        {
          "name": "SrcFile",
          "locator": "parser/src_file/SrcFile/Using/error_section",
          "usings": [
            2,
            4
          ],
          "error_sections": [
            3
          ],
          "pre_trivia": [
            0,
            1
          ],
          "post_trivia": [
            5
          ],
          "children": [
            {
              "name": "Trivia",
              "kind": "LineCommentTrivia",
              "string": "// comment"
            },
            {
              "name": "Trivia",
              "kind": "EndOfLineTrivia",
              "string": "\n"
            },
            {
              "name": "UsingPony",
              "path": 1,
              "children": [
                {
                  "name": "Keyword",
                  "string": "use",
                  "post_trivia": [
                    1
                  ],
                  "children": [
                    {
                      "name": "Span"
                    },
                    {
                      "name": "Trivia",
                      "kind": "WhiteSpaceTrivia",
                      "string": " "
                    }
                  ]
                },
                {
                  "name": "LiteralString",
                  "kind": "StringLiteral",
                  "value": "bar",
                  "post_trivia": [
                    3,
                    4
                  ],
                  "children": [
                    {
                      "name": "Token",
                      "string": "\"",
                      "children": [
                        {
                          "name": "Span"
                        }
                      ]
                    },
                    {
                      "name": "Span"
                    },
                    {
                      "name": "Token",
                      "string": "\"",
                      "children": [
                        {
                          "name": "Span"
                        }
                      ]
                    },
                    {
                      "name": "Trivia",
                      "kind": "EndOfLineTrivia",
                      "string": "\n"
                    },
                    {
                      "name": "Trivia",
                      "kind": "EndOfLineTrivia",
                      "string": "\n"
                    }
                  ]
                }
              ]
            },
            {
              "name": "ErrorSection",
              "message": "Expected either a \"use\" statement or a type definition",
              "children": [
                {
                  "name": "Span"
                },
                {
                  "name": "Trivia",
                  "kind": "EndOfLineTrivia",
                  "string": "\n"
                },
                {
                  "name": "Trivia",
                  "kind": "EndOfLineTrivia",
                  "string": "\n"
                }
              ]
            },
            {
              "name": "UsingPony",
              "path": 1,
              "children": [
                {
                  "name": "Keyword",
                  "string": "use",
                  "post_trivia": [
                    1
                  ],
                  "children": [
                    {
                      "name": "Span"
                    },
                    {
                      "name": "Trivia",
                      "kind": "WhiteSpaceTrivia",
                      "string": " "
                    }
                  ]
                },
                {
                  "name": "LiteralString",
                  "kind": "StringLiteral",
                  "value": "baz",
                  "post_trivia": [
                    3
                  ],
                  "children": [
                    {
                      "name": "Token",
                      "string": "\"",
                      "children": [
                        {
                          "name": "Span"
                        }
                      ]
                    },
                    {
                      "name": "Span"
                    },
                    {
                      "name": "Token",
                      "string": "\"",
                      "children": [
                        {
                          "name": "Span"
                        }
                      ]
                    },
                    {
                      "name": "Trivia",
                      "kind": "EndOfLineTrivia",
                      "string": "\n"
                    }
                  ]
                }
              ]
            },
            {
              "name": "Trivia",
              "kind": "EndOfFileTrivia",
              "string": ""
            }
          ]
        }
      """

    _Assert.test_all(
      h, [ _Assert.test_match(h, rule, setup.data, src, exp, true) ])

class iso _TestParserSrcFileTypedefMultiple is UnitTest
  fun name(): String => "parser/src_file/Typedef/Multiple"
  fun exclusion_group(): String => "parser/src_file"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.src_file.src_file

    let src =
      recover val
        """
          class A
            new create() => None
          interface B
        """.clone() .> replace("\r\n", "\n")
      end
    let exp =
      """
        {
          "name": "SrcFile",
          "locator": "parser/src_file/Typedef/Multiple",
          "type_defs": [
            0,
            1
          ],
          "post_trivia": [
            2
          ],
          "children": [
            {
              "name": "TypedefClass",
              "kind": 0,
              "identifier": 1,
              "members": 2,
              "children": [
                {
                  "name": "Keyword",
                  "string": "class",
                  "post_trivia": [
                    1
                  ],
                  "children": [
                    {
                      "name": "Span"
                    },
                    {
                      "name": "Trivia",
                      "kind": "WhiteSpaceTrivia",
                      "string": " "
                    }
                  ]
                },
                {
                  "name": "Identifier",
                  "string": "A",
                  "post_trivia": [
                    1,
                    2
                  ],
                  "children": [
                    {
                      "name": "Span"
                    },
                    {
                      "name": "Trivia",
                      "kind": "EndOfLineTrivia",
                      "string": "\n"
                    },
                    {
                      "name": "Trivia",
                      "kind": "WhiteSpaceTrivia",
                      "string": "  "
                    }
                  ]
                },
                {
                  "name": "TypedefMembers",
                  "methods": [
                    0
                  ],
                  "children": [
                    {
                      "name": "TypedefMethod",
                      "kind": 0,
                      "identifier": 1,
                      "body": 5,
                      "children": [
                        {
                          "name": "Keyword",
                          "string": "new",
                          "post_trivia": [
                            1
                          ],
                          "children": [
                            {
                              "name": "Span"
                            },
                            {
                              "name": "Trivia",
                              "kind": "WhiteSpaceTrivia",
                              "string": " "
                            }
                          ]
                        },
                        {
                          "name": "Identifier",
                          "string": "create",
                          "children": [
                            {
                              "name": "Span"
                            }
                          ]
                        },
                        {
                          "name": "Token",
                          "string": "(",
                          "children": [
                            {
                              "name": "Span"
                            }
                          ]
                        },
                        {
                          "name": "Token",
                          "string": ")",
                          "post_trivia": [
                            1
                          ],
                          "children": [
                            {
                              "name": "Span"
                            },
                            {
                              "name": "Trivia",
                              "kind": "WhiteSpaceTrivia",
                              "string": " "
                            }
                          ]
                        },
                        {
                          "name": "Token",
                          "string": "=>",
                          "post_trivia": [
                            1
                          ],
                          "children": [
                            {
                              "name": "Span"
                            },
                            {
                              "name": "Trivia",
                              "kind": "WhiteSpaceTrivia",
                              "string": " "
                            }
                          ]
                        },
                        {
                          "name": "ExpAtom",
                          "body": 0,
                          "children": [
                            {
                              "name": "Identifier",
                              "string": "None",
                              "post_trivia": [
                                1
                              ],
                              "children": [
                                {
                                  "name": "Span"
                                },
                                {
                                  "name": "Trivia",
                                  "kind": "EndOfLineTrivia",
                                  "string": "\n"
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
              "name": "TypedefClass",
              "kind": 0,
              "identifier": 1,
              "children": [
                {
                  "name": "Keyword",
                  "string": "interface",
                  "post_trivia": [
                    1
                  ],
                  "children": [
                    {
                      "name": "Span"
                    },
                    {
                      "name": "Trivia",
                      "kind": "WhiteSpaceTrivia",
                      "string": " "
                    }
                  ]
                },
                {
                  "name": "Identifier",
                  "string": "B",
                  "post_trivia": [
                    1
                  ],
                  "children": [
                    {
                      "name": "Span"
                    },
                    {
                      "name": "Trivia",
                      "kind": "EndOfLineTrivia",
                      "string": "\n"
                    }
                  ]
                }
              ]
            },
            {
              "name": "Trivia",
              "kind": "EndOfFileTrivia",
              "string": ""
            }
          ]
        }
      """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])

class iso _TestParserSrcFileTypedefSingle is UnitTest
  fun name(): String => "parser/src_file/Typedef/Single"
  fun exclusion_group(): String => "parser/src_file"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.src_file.src_file

    let src =
      recover val
        """
          class A
            new create() =>
              None
        """.clone() .> replace("\r\n", "\n")
      end

    let exp =
      """
        {
          "name": "SrcFile",
          "locator": "parser/src_file/Typedef/Single",
          "type_defs": [
            0
          ],
          "post_trivia": [
            1
          ],
          "children": [
            {
              "name": "TypedefClass",
              "kind": 0,
              "identifier": 1,
              "members": 2,
              "children": [
                {
                  "name": "Keyword",
                  "string": "class",
                  "post_trivia": [
                    1
                  ],
                  "children": [
                    {
                      "name": "Span"
                    },
                    {
                      "name": "Trivia",
                      "kind": "WhiteSpaceTrivia",
                      "string": " "
                    }
                  ]
                },
                {
                  "name": "Identifier",
                  "string": "A",
                  "post_trivia": [
                    1,
                    2
                  ],
                  "children": [
                    {
                      "name": "Span"
                    },
                    {
                      "name": "Trivia",
                      "kind": "EndOfLineTrivia",
                      "string": "\n"
                    },
                    {
                      "name": "Trivia",
                      "kind": "WhiteSpaceTrivia",
                      "string": "  "
                    }
                  ]
                },
                {
                  "name": "TypedefMembers",
                  "methods": [
                    0
                  ],
                  "children": [
                    {
                      "name": "TypedefMethod",
                      "kind": 0,
                      "identifier": 1,
                      "body": 5,
                      "children": [
                        {
                          "name": "Keyword",
                          "string": "new",
                          "post_trivia": [
                            1
                          ],
                          "children": [
                            {
                              "name": "Span"
                            },
                            {
                              "name": "Trivia",
                              "kind": "WhiteSpaceTrivia",
                              "string": " "
                            }
                          ]
                        },
                        {
                          "name": "Identifier",
                          "string": "create",
                          "children": [
                            {
                              "name": "Span"
                            }
                          ]
                        },
                        {
                          "name": "Token",
                          "string": "(",
                          "children": [
                            {
                              "name": "Span"
                            }
                          ]
                        },
                        {
                          "name": "Token",
                          "string": ")",
                          "post_trivia": [
                            1
                          ],
                          "children": [
                            {
                              "name": "Span"
                            },
                            {
                              "name": "Trivia",
                              "kind": "WhiteSpaceTrivia",
                              "string": " "
                            }
                          ]
                        },
                        {
                          "name": "Token",
                          "string": "=>",
                          "post_trivia": [
                            1,
                            2
                          ],
                          "children": [
                            {
                              "name": "Span"
                            },
                            {
                              "name": "Trivia",
                              "kind": "EndOfLineTrivia",
                              "string": "\n"
                            },
                            {
                              "name": "Trivia",
                              "kind": "WhiteSpaceTrivia",
                              "string": "    "
                            }
                          ]
                        },
                        {
                          "name": "ExpAtom",
                          "body": 0,
                          "children": [
                            {
                              "name": "Identifier",
                              "string": "None",
                              "post_trivia": [
                                1
                              ],
                              "children": [
                                {
                                  "name": "Span"
                                },
                                {
                                  "name": "Trivia",
                                  "kind": "EndOfLineTrivia",
                                  "string": "\n"
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
              "kind": "EndOfFileTrivia",
              "string": ""
            }
          ]
        }
      """

    _Assert.test_all(h, [ _Assert.test_match(h, rule, setup.data, src, exp) ])

class iso _TestParserSrcFileStdlibEnv is UnitTest
  fun name(): String => "parser/src_file/stdlib/env"
  fun exclusion_group(): String => "parser/src_file"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.src_file.src_file

    let src =
      """
        use @pony_os_stdin_setup[Bool]()
        use @pony_os_stdout_setup[None]()

        class val Env
          \"\"\"
          An environment holds the command line and other values injected into the
          program by default by the runtime.
          \"\"\"
      """
      //     let root: AmbientAuth
      //       \"\"\"
      //       The root capability.
      //       \"\"\"

      //     let input: InputStream
      //       \"\"\"
      //       Stdin represented as an actor.
      //       \"\"\"

      //     let out: OutStream
      //       \"\"\"Stdout\"\"\"

      //     let err: OutStream
      //       \"\"\"Stderr\"\"\"

      //     let args: Array[String] val
      //       \"\"\"The command line used to start the program.\"\"\"

      //     let vars: Array[String] val
      //       \"\"\"The program's environment variables.\"\"\"

      //     let exitcode: {(I32)} val
      //       \"\"\"
      //       Sets the environment's exit code. The exit code of the root environment will
      //       be the exit code of the application, which defaults to 0.
      //       \"\"\"

      //     new _create(
      //       argc: U32,
      //       argv: Pointer[Pointer[U8]] val,
      //       envp: Pointer[Pointer[U8]] val)
      //     =>
      //       \"\"\"
      //       Builds an environment from the command line. This is done before the Main
      //       actor is created.
      //       \"\"\"
      //       root = AmbientAuth._create()
      //       @pony_os_stdout_setup()

      //       input = Stdin._create(@pony_os_stdin_setup())
      //       out = StdStream._out()
      //       err = StdStream._err()

      //       args = _strings_from_pointers(argv, argc.usize())
      //       vars = _strings_from_pointers(envp, _count_strings(envp))

      //       exitcode = {(code: I32) => @pony_exitcode(code) }

      //     new val create(
      //       root': AmbientAuth,
      //       input': InputStream, out': OutStream,
      //       err': OutStream, args': Array[String] val,
      //       vars': Array[String] val,
      //       exitcode': {(I32)} val)
      //     =>
      //       \"\"\"
      //       Build an artificial environment. A root capability must be supplied.
      //       \"\"\"
      //       root = root'
      //       input = input'
      //       out = out'
      //       err = err'
      //       args = args'
      //       vars = vars'
      //       exitcode = exitcode'

      //     fun tag _count_strings(data: Pointer[Pointer[U8]] val): USize =>
      //       if data.is_null() then
      //         return 0
      //       end

      //       var i: USize = 0

      //       while
      //         let entry = data._apply(i)
      //         not entry.is_null()
      //       do
      //         i = i + 1
      //       end
      //       i

      //     fun tag _strings_from_pointers(
      //       data: Pointer[Pointer[U8]] val,
      //       len: USize)
      //       : Array[String] iso^
      //     =>
      //       let array = recover Array[String](len) end
      //       var i: USize = 0

      //       while i < len do
      //         let entry = data._apply(i = i + 1)
      //         array.push(recover String.copy_cstring(entry) end)
      //       end

      //       array
      // """

    let src2 = src.clone()
    src2.replace("\\\"", "\"")

    let src_len = src2.size()

    _Assert.test_all(
      h,
      [ _Assert.test_with(
          h, rule, setup.data, consume src,
          {(success, values) =>
            let len = success.next.index() - success.start.index()
            ( len == src_len
            , "expected length " + src_len.string() + ", got " + len.string() )
          })
      ])
