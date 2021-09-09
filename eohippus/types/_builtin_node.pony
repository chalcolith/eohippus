use "collections/persistent"

use ast = "../ast"
use parser = "../parser"

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
