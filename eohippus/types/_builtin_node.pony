use "collections/persistent"

use ast = "../ast"
use parser = "../parser"

class val _BuiltinNode is ast.Node
  let _src_info: ast.SrcInfo

  new val create(name: String, segments: List[parser.Segment], index: USize) =>
    let segment = try segments(index)? else Nil[parser.Segment] end

    _src_info = ast.SrcInfo("pony:builtin/" + name, parser.Loc(segment, 0),
      parser.Loc(segment, name.size()))

  fun src_info(): ast.SrcInfo => _src_info
  fun ast_type(): (AstType | None) => None

  fun string(): String iso^ =>
    "<" + _src_info.locator() + ">"
