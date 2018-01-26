
use "collections"

use "kiuatan"
use "../eoh-ast"

primitive PonyGrammar[CH: EohInput val]

  fun _eof(): ParseRule[CH, AstNode[CH] val] val =>
    recover
      ParseRule[CH, AstNode[CH] val](
        "EOF",
        RuleNot[CH, AstNode[CH] val](
          RuleAny[CH, AstNode[CH] val]()
        ))
    end

  fun _ws(): ParseRule[CH, AstNode[CH] val] val =>
    recover
      ParseRule[CH, AstNode[CH] val](
        "WS",
        RuleClass[CH, AstNode[CH] val].from_iter(
          [as CH: ' '; '\t'; '\r'; '\n'].values()
        ))
    end

  fun _nws(): ParseRule[CH, AstNode[CH] val] val =>
    recover
      ParseRule[CH, AstNode[CH] val](
        "NWS",
        RuleClass[CH, AstNode[CH] val].from_iter(
          [as CH: ' '; '\t'; '\r'; '\n'].values()
        ))
    end

  fun _file_item(): ParseRule[CH, AstNode[CH] val] val =>
    recover
      ParseRule[CH, AstNode[CH] val](
        "FileItem",
        RuleChoice[CH, AstNode[CH] val](
          [ _nws()
            _ws()
          ]))
    end

  fun _file_item_seq(): ParseRule[CH, AstNode[CH] val] val =>
    recover
      ParseRule[CH, AstNode[CH] val](
        "FileItemSeq",
        RuleSequence[CH, AstNode[CH] val](
          [ RuleRepeat[CH, AstNode[CH] val](_file_item())
            _eof()
          ]))
    end

  fun build(): ParseRule[CH, AstNode[CH] val] val =>
    recover _file_item_seq() end
