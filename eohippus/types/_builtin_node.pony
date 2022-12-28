use "collections/persistent"

use ast = "../ast"
use json = "../json"
use parser = "../parser"

class val _BuiltinNode is ast.Node
  let _src_info: ast.SrcInfo

  new val create(name: String, segments: List[parser.Segment], index: USize) =>
    let segment =
      try
        var cur = segments
        var i: USize = 0
        while i < index do
          cur = cur.tail()?
          i = i + 1
        end
        cur
      else
        Nil[parser.Segment]
      end

    _src_info = ast.SrcInfo("pony:builtin/" + name, parser.Loc(segment, 0),
      parser.Loc(segment, name.size()))

  fun src_info(): ast.SrcInfo => _src_info
  fun has_error(): Bool => false
  fun ast_type(): (AstType | None) => None

  fun info(): json.Item iso^ =>
    recover
      json.Object([
        ("node", "BUILTIN")
        ("locator", _src_info.locator())
      ])
    end
