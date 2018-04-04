
use "kiuatan"
use "../eoh-ast"

primitive GrammarExpressions[CH: (Unsigned & Integer[CH])]

  fun literal_bool(gctx: GrammarContext[CH] box):
    ParseRule[CH, AstNode[CH] val] val
  =>
    recover
      ParseRule[CH, AstNode[CH] val](
        "LiteralBool",
        RuleChoice[CH, AstNode[CH] val](
          [ RuleLiteral[CH, AstNode[CH] val](
              _Utils.chars[CH]("true"),
              {(ctx): (AstNode[CH] | None) =>
                recover
                  AstNodeLiteralBool[CH](ctx.cur_result.start,
                    ctx.cur_result.next, true)
                end
              })
            RuleLiteral[CH, AstNode[CH] val](
              _Utils.chars[CH]("false"),
              {(ctx): (AstNode[CH] | None) =>
                recover
                  AstNodeLiteralBool[CH](ctx.cur_result.start,
                    ctx.cur_result.next, false)
                end
              })
          ]
        )
      )
    end
