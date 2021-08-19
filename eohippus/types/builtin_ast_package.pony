use "collections/persistent"
use "kiuatan"
use "../ast"
use "../chars"

class val BuiltinAstPackage[CH: ((U8 | U16) & UnsignedInteger[CH])]
  is AstPackage[CH]

  let _name: String = "builtin"
  let _locator: String = "pony:builtin"

  let _names: Array[String]
  let _segments: List[ReadSeq[CH] val]
  let _all_types: List[AstType[CH]]

  let _bool_name: String = "Bool"
  let _bool: AstType[CH]

  new val create() =>
    _names = [
      _bool_name
    ]

    _segments = _make_segments(_names)

    _bool = object val is AstType[CH]
      let _full_name: String = _name + "/" + _bool_name
      let _bool_node: AstNode[CH] = _Node[CH](_bool_name, _segments)

      fun val name(): String => _bool_name
      fun val full_name(): String => _full_name
      fun val node(): AstNode[CH] => _bool_node

      fun string(): String iso^ => _full_name.clone()
    end

    _all_types = Lists[AstType[CH]]([
      _bool
    ])

  fun name(): String => _name
  fun locator(): String => _locator
  fun all_types(): List[AstType[CH]] => _all_types

  fun bool(): AstType[CH] => _bool

  fun tag _make_segments(names: ReadSeq[String]): List[ReadSeq[CH] val] =>
    var list: List[ReadSeq[CH] val] = Nil[ReadSeq[CH] val]
    for n in names.values() do
      list = Cons[ReadSeq[CH] val](recover Utf.from_utf8[CH](n) end, list)
    end
    list

class val _Node[CH: ((U8 | U16) & UnsignedInteger[CH])] is AstNode[CH]
  let _src_info: SrcInfo[CH]

  new val create(name: String, segments: List[ReadSeq[CH] val]) =>
    let segment = _get_segment(name, segments)

    _src_info = SrcInfo[CH]("pony:builtin/" + name, Loc[CH](segment, 0),
      Loc[CH](segment, name.size()))

  fun src_info(): SrcInfo[CH] => _src_info
  fun ast_type(): (AstType[CH] | None) => None

  fun string(): String iso^ =>
    "<" + _src_info.locator() + ">"

  fun tag _get_segment(name: String, segments: List[ReadSeq[CH] val])
    : List[ReadSeq[CH] val]
  =>
    let name' = Utf.from_utf8[CH](name)
    var seg: List[ReadSeq[CH] val] = segments
    try
      while true do
        match seg
        | let cons: Cons[ReadSeq[CH] val] =>
          if Utf.string_equals[CH](name, cons.head()) then
            return cons
          else
            seg = seg.tail()?
          end
        else
          break
        end
      end
    end
    Nil[ReadSeq[CH] val]
