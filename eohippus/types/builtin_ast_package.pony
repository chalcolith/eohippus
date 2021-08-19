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


class val _BuiltinNode is ast.Node
  let _src_info: ast.SrcInfo

  new val create(name: String, segments: List[parser.Segment]) =>
    let segment = _get_segment(name, segments)

    _src_info = ast.SrcInfo("pony:builtin/" + name, parser.Loc(segment, 0),
      parser.Loc(segment, name.size()))

  fun src_info(): ast.SrcInfo => _src_info
  fun ast_type(): (AstType | None) => None

  fun string(): String iso^ =>
    "<" + _src_info.locator() + ">"

  fun tag _get_segment(name: String, segments: List[parser.Segment])
    : List[parser.Segment]
  =>
    var seg: List[parser.Segment] = segments
    try
      while true do
        match seg
        | let cons: Cons[parser.Segment] =>
          if _seg_eq(cons.head(), name) then
            return cons
          else
            seg = seg.tail()?
          end
        else
          break
        end
      end
    end
    Nil[parser.Segment]

  fun tag _seg_eq(seg: parser.Segment, str: String) : Bool =>
    let seg_len = seg.size()
    let str_len = str.size()
    if seg_len != str_len then return false end
    if seg_len == 0 then return true end
    try
      var i = USize(0)
      while i < seg_len do
        if seg(i)? != str(i)? then return false end
        i = i + 1
      end
    end
    true
