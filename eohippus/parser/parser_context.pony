use "collections/persistent"
use "../types"

class val ParserContext[CH: ((U8 | U16) & UnsignedInteger[CH])]
  let _builtin: BuiltinAstPackage[CH]
  let _packages: List[AstPackage[CH] val]

  new val create(packages': ReadSeq[AstPackage[CH] val] val) =>
    _builtin = BuiltinAstPackage[CH]
    _packages = Lists[AstPackage[CH] val].from(packages'.values())

  fun builtin(): BuiltinAstPackage[CH] => _builtin
  fun other_packages(): ReadSeq[AstPackage[CH] val] => _packages
  fun all_packages(): ReadSeq[AstPackage[CH] val] =>
    Cons[AstPackage[CH] val](_builtin, _packages)
