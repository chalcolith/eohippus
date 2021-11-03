use "collections/persistent"

use ast = "../ast"
use parser = "../parser"

class val BuiltinAstPackage is AstPackage
  let _package_name: String = "builtin"
  let _locator: String = "pony:builtin"

  let _segments: List[parser.Segment]
  let _all_types: List[AstType]

  let _bool_name: String = "Bool"
  let _bool: AstType

  let _string_name: String = "String"
  let _string: AstType

  new val create() =>
    _segments = Lists[parser.Segment]([
      _bool_name
      _string_name
    ])

    _bool =
      object val is AstType
        let _full_name: String = _package_name + "/" + _bool_name
        let _bool_node: ast.Node = _BuiltinNode(_bool_name, _segments, 0)

        fun val name(): String => _bool_name
        fun val full_name(): String => _full_name
        fun val node(): ast.Node => _bool_node
        fun string(): String iso^ => _full_name.clone()
      end

    _string =
      object val is AstType
        let _full_name: String = _package_name + "/" + _string_name
        let _string_node: ast.Node = _BuiltinNode(_string_name, _segments, 1)

        fun val name(): String => _string_name
        fun val full_name(): String => _full_name
        fun val node(): ast.Node => _string_node
        fun string(): String iso^ => _full_name.clone()
      end

    _all_types = Lists[AstType]([
      _bool
      _string
    ])

  fun name(): String => _package_name
  fun locator(): String => _locator
  fun all_types(): List[AstType] => _all_types

  fun bool_type(): AstType => _bool
  fun string_type(): AstType => _string
