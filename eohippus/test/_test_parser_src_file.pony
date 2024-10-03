use "itertools"
use "pony_test"

use ast = "../ast"
use json = "../json"
use parser = "../parser"
use ".."

primitive _TestParserSrcFile
  fun apply(test: PonyTest) =>
    test(_TestParserSrcFileStdlibErrorSection)
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

class iso _TestParserSrcFileStdlibErrorSection is UnitTest
  fun name(): String => "parser/src_file/stdlib/error_section"
  fun exclusion_group(): String => "parser/src_file"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.src_file.src_file

    let src =
      """
        use @snprintf[I32](str: Pointer[U8] tag, size: USize, fmt: Pointer[U8] tag, ...) if not windows
        use @_snprintf[I32](str: Pointer[U8] tag, count: USize, fmt: Pointer[U8] tag, ...) if windows

        primitive _ToString

          fun _f64(x: F64): String iso^ =>
            recover
              var s = String(31)
              var f = String(31) .> append("%g")

              ifdef windows then
                @_snprintf(s.cstring(), s.space(), f.cstring(), x)
              else
                @snprintf(s.cstring(), s.space(), f.cstring(), x)
              end

              s .> recalc()
            end
      """

    let src2 = src.clone()
    src2.replace("\r\n", "\n")
    src2.replace("\\\"", "\"")

    let src_len = src2.size()

    _Assert.test_all(
      h,
      [ _Assert.test_with(
          h, rule, setup.data, consume src2,
          {(success, values) =>
            let len = success.next.index() - success.start.index()
            ( len == src_len
            , "expected length " + src_len.string() + ", got " + len.string() )
          })
      ])
