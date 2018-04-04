
use "collections"
use "itertools"

use "kiuatan"
use "../eoh-ast"

primitive PonyGrammar[CH: (Unsigned & Integer[CH])]

  fun eof(gctx: GrammarContext[CH] box): ParseRule[CH, AstNode[CH] val] val =>
    recover
      ParseRule[CH, AstNode[CH] val](
        "EOF",
        RuleNot[CH, AstNode[CH] val](
          RuleAny[CH, AstNode[CH] val]()
        ))
    end

  fun ws(gctx: GrammarContext[CH] box): ParseRule[CH, AstNode[CH] val] val =>
    recover
      ParseRule[CH, AstNode[CH] val](
        "WS",
        RuleClass[CH, AstNode[CH] val]
          .from_iter(_Utils.chari[CH](" \t\n\r")))
    end

  fun nws(gctx: GrammarContext[CH] box): ParseRule[CH, AstNode[CH] val] val =>
    recover
      ParseRule[CH, AstNode[CH] val](
        "NWS",
        RuleSequence[CH, AstNode[CH] val](
          [ RuleNot[CH, AstNode[CH] val](
              RuleClass[CH, AstNode[CH] val]
                .from_iter(_Utils.chari[CH](" \t\n\r")))
            RuleAny[CH, AstNode[CH] val]
          ])
        )
    end


primitive _Utils
  fun chari[CH: (Unsigned & Integer[CH])](str: String): Iterator[CH] =>
    Iter[U8](str.values()).map[CH]({(ch) => CH.from[U8](ch)})

  fun chars[CH: (Unsigned & Integer[CH])](str: String): ReadSeq[CH] =>
    let arr = Array[CH]
    for c in chari[CH](str) do
      arr.push(c)
    end
    arr
