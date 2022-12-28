use json = "../json"

class val Jump is (Node & NodeWithChildren)
  let _src_info: SrcInfo
  let _children: NodeSeq

  let _keyword: Keyword
  let _rhs: (Node | None)

  new val create(
    src_info': SrcInfo,
    children': NodeSeq,
    keyword': Keyword,
    rhs': (Node | None))
  =>
    _src_info = src_info'
    _children = children'
    _keyword = keyword'
    _rhs = rhs'

  fun src_info(): SrcInfo => _src_info

  fun info(): json.Item iso^ =>
    recover
      let properties =
        [as (String, json.Item):
          ("node", "Jump")
          ("keyword", _keyword.info())
        ]
      match _rhs
      | let n: Node =>
        properties.push(("rhs", n.info()))
      end
      json.Object(properties)
    end

  fun children(): NodeSeq => _children

  fun keyword(): Keyword => _keyword

  fun rhs(): (Node | None) => _rhs
