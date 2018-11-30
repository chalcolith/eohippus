
use "kiuatan"

type LiteralAstType is
    (AstBool | AstUnsigned | AstSigned | AstFloat | AstString)
type LiteralPonyType is
    (Bool | U128 | I128 | F64 | String)

class LiteralNode[CH: (U8 | U16), AstType: LiteralAstType val,
  PonyType: LiteralPonyType val] is AstNode[CH]
  let start: Loc[CH]
  let next: Loc[CH]
  let ast_type: AstType
  let value: PonyType

  new create(start': Loc[CH], next': Loc[CH], ast_type': AstType,
    value': PonyType)
  =>
    start = start'
    next = next'
    ast_type = ast_type'
    value = value'

  fun string(): String iso^ =>
    let str =
      recover
        let str' = "Literal("
        match this.value
        | let _: Bool =>
          str'.append("Bool = ")
        | let _: U128 =>
          str'.append("U128 = ")
        | let _: I128 =>
          str'.append("I128 = ")
        | let _: F64 =>
          str'.append("F64 = ")
        end
        str'.append(this.value.string())
        str'.append(")")
      end
    consume str
