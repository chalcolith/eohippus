use "collections/persistent"

use ast = "../ast"
use parser = "../parser"

class val BuiltinAstPackage is AstPackage
  let _name: String = "builtin"
  let _locator: String = "pony:builtin"

  let _segments: List[parser.Segment]
  let _all_types: List[AstType]

  let _bool_name: String = "Bool"
  let _bool: AstType

  new val create() =>
    _segments = Lists[parser.Segment]([
      _bool_name
    ])

    _bool = object val is AstType
      let _full_name: String = _name + "/" + _bool_name
      let _bool_node: ast.Node = _BuiltinNode(_bool_name, _segments)

      fun val name(): String => _bool_name
      fun val full_name(): String => _full_name
      fun val node(): ast.Node => _bool_node

      fun string(): String iso^ => _full_name.clone()
    end

    _all_types = Lists[AstType]([
      _bool
    ])

  fun name(): String => _name
  fun locator(): String => _locator
  fun all_types(): List[AstType] => _all_types

  fun bool(): AstType => _bool
