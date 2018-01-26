
use "kiuatan"
use "../eoh-ast"

primitive PonyGrammar[CH: (U8 | U16)]
  fun _eof(): ParseRule[CH, AstNode[CH] val] box^ =>
    ParseRule[CH, AstNode[CH]](
      "EOF",
      RuleNot[CH, AstNode[CH]](
        RuleAny[CH, AstNode[CH]]()
      )
    )
  
  fun _ws(): ParseRule[CH, AstNode[CH] val] box^ =>
    ParseRule[CH, AstNode[CH]](
      "WS",
      RuleClass[CH, AstNode[CH]].from_iter(
        [as CH: ' '; '\t'; '\r'; '\n'].values()
      )
    )
  
  fun _nws(): ParseRule[CH, AstNode[CH] val] box^ =>
    ParseRule[CH, AstNode[CH]](
      "NWS",
      RuleClass[CH, AstNode[CH]].from_iter(
        [as CH: ' '; '\t'; '\r'; '\n'].values()
      )
    )

  fun _file_item(): ParseRule[CH, AstNode[CH] val] box^ =>
    ParseRule(
      "FileItem",
      RuleChoice[CH, AstNode[CH]](
        [ _nws(),
          _ws()
        ]
      )
    )

  fun _file_item_seq(): ParseRule[CH, AstNode[CH] val] box^ =>
    ParseRule(
      "FileItemSeq",
      RuleSequence[CH, AstNode[CH]](
        [ RuleRepeat[CH, AstNode[CH]](_file_item()),
          _eof()
        ]
      )
    )

  new create(): ParseRule[CH, AstNode[CH] val] box^ =>
    _file_item_seq()
  