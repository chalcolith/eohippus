
use "collections"
use "itertools"

use "kiuatan"
use "../eoh-ast"

primitive PonyGrammar[CH: (Unsigned & Integer[CH])]

  fun _eof(): ParseRule[CH, AstNode[CH] val] val =>
    recover
      ParseRule[CH, AstNode[CH] val](
        "EOF",
        RuleNot[CH, AstNode[CH] val](
          RuleAny[CH, AstNode[CH] val]()
        ))
    end

  fun _char_iter(str: String): Iterator[CH] =>
    Iter[U8](str.values()).map[CH]({(ch) => CH.from[U8](ch)})

  fun _ws(): ParseRule[CH, AstNode[CH] val] val =>
    recover
      ParseRule[CH, AstNode[CH] val](
        "WS",
        RuleClass[CH, AstNode[CH] val].from_iter(_char_iter(" \t\n\r")))
    end

  fun _nws(): ParseRule[CH, AstNode[CH] val] val =>
    recover
      ParseRule[CH, AstNode[CH] val](
        "NWS",
        RuleClass[CH, AstNode[CH] val].from_iter(_char_iter(" \t\n\r")))
    end

  fun _file_item(): ParseRule[CH, AstNode[CH] val] val =>
    recover
      ParseRule[CH, AstNode[CH] val](
        "FileItem",
        RuleChoice[CH, AstNode[CH] val](
          [ _nws()
            _ws() ],
          {(ctx): (AstNode[CH] val | None) =>
            recover
              FileItem[CH](ctx.cur_result.start, ctx.cur_result.next)
            end
          }))
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

  fun apply(): ParseRule[CH, AstNode[CH] val] val =>
    recover _file_item_seq() end
