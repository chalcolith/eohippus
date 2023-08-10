use "collections/persistent"

use ast = "../ast"
use parser = "../parser"

class val BuiltinAstPackage is AstPackage
  let _package_name: String = "builtin"
  let _locator: String = "pony:builtin"

  let _all_types: List[AstType]

  let _bool_name: String = "Bool"
  let _bool: AstType

  let _string_name: String = "String"
  let _string: AstType

  let _source_loc_name: String = "SourceLoc"
  let _source_loc: AstType

  new val create() =>
    _bool =
      object val is AstType
        let _full_name: String = _package_name + "/" + _bool_name
        let _bool_node: ast.Node = _make_node(_locator, _bool_name)

        fun val name(): String => _bool_name
        fun val full_name(): String => _full_name
        fun val node(): ast.Node => _bool_node
        fun string(): String iso^ => _full_name.clone()
      end

    _string =
      object val is AstType
        let _full_name: String = _package_name + "/" + _string_name
        let _string_node: ast.Node = _make_node(_locator, _string_name)

        fun val name(): String => _string_name
        fun val full_name(): String => _full_name
        fun val node(): ast.Node => _string_node
        fun string(): String iso^ => _full_name.clone()
      end

    _source_loc =
      object val is AstType
        let _full_name: String = _package_name + "/" + _source_loc_name
        let _source_loc_node: ast.Node = _make_node(_locator, _source_loc_name)

        fun val name(): String => _source_loc_name
        fun val full_name(): String => _full_name
        fun val node(): ast.Node => _source_loc_node
        fun string(): String iso^ => _full_name.clone()
      end

    _all_types = Lists[AstType]([
      _bool
      _string
      _source_loc
    ])

  fun tag _make_node(locator': parser.Locator, name': String): ast.Node =>
    let segment = Cons[ReadSeq[U8] val](name', Nil[ReadSeq[U8] val])
    let src_info = ast.SrcInfo(
      locator',
      parser.Loc(segment, 0),
      parser.Loc(segment, name'.size()))
    ast.NodeWith[_BuiltinNode](src_info, [], _BuiltinNode(name'))

  fun name(): String => _package_name
  fun locator(): String => _locator
  fun all_types(): List[AstType] => _all_types

  fun bool_type(): AstType => _bool
  fun string_type(): AstType => _string
  fun source_loc_type(): AstType => _source_loc
