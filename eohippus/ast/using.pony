use json = "../json"
use parser = "../parser"
use ".."

class val UsingPony is (Node & NodeWithChildren)
  let _src_info: SrcInfo
  let _children: NodeSeq
  let _identifier: (Identifier | None)
  let _path: LiteralString
  let _def_flag: Bool
  let _def_id: (Identifier | None)

  new val create(src_info': SrcInfo, children': NodeSeq,
    identifier': (Identifier | None), path': LiteralString,
    def_flag': Bool, def_id': (Identifier | None))
  =>
    _src_info = src_info'
    _children = children'
    _identifier = identifier'
    _path = path'
    _def_flag = def_flag'
    _def_id = def_id'

  fun src_info(): SrcInfo => _src_info

  fun info(): json.Item val =>
    recover
      let items = Array[(String, json.Item)]
      items.push(("node", "Using"))
      items.push(("path", _path.info()))
      match _identifier
      | let id: Identifier =>
        items.push(("id", id.info()))
      end
      match _def_id
      | let id: Identifier =>
        items.push(("ifdef", id.info()))
        items.push(("ifdef_flag", _def_flag))
      end
      json.Object(items)
    end

  fun children(): NodeSeq => _children

  fun identifier(): (Identifier | None) => _identifier
  fun path(): LiteralString => _path
  fun def_flag(): Bool => _def_flag
  fun def_id(): (Identifier | None) => _def_id
