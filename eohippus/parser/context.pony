use "collections/persistent"

use types = "../types"

class val Context
  let _builtin: types.BuiltinAstPackage
  let _packages: List[types.AstPackage val]

  new val create(packages': ReadSeq[types.AstPackage val] val) =>
    _builtin = types.BuiltinAstPackage
    _packages = Lists[types.AstPackage val].from(packages'.values())

  fun builtin(): types.BuiltinAstPackage => _builtin
  fun other_packages(): ReadSeq[types.AstPackage val] => _packages
  fun all_packages(): ReadSeq[types.AstPackage val] =>
    Cons[types.AstPackage val](_builtin, _packages)
