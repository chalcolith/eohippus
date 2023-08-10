use json = "../json"
use parser = "../parser"
use ".."

type Using is UsingPony

class val UsingPony is NodeData
  let identifier: (NodeWith[Identifier] | None)
  let path: NodeWith[LiteralString]
  let def_true: Bool
  let define: (NodeWith[Identifier] | None)

  new val create(
    identifier': (NodeWith[Identifier] | None),
    path': NodeWith[LiteralString],
    def_true': Bool,
    define': (NodeWith[Identifier] | None))
  =>
    identifier = identifier'
    path = path'
    def_true = def_true'
    define = define'

  fun name(): String => "Using"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    match identifier
    | let identifier': NodeWith[Identifier] =>
      props.push(("identifier", identifier'.get_json()))
    end
    props.push(("path", path.get_json()))
    match define
    | let define': NodeWith[Identifier] =>
      props.push(("def_true", def_true.string()))
      props.push(("define", define'.get_json()))
    end

// class val UsingPony is (Node & NodeWithChildren)
//   let _src_info: SrcInfo
//   let _children: NodeSeq
//   let _identifier: (Identifier | None)
//   let _path: LiteralString
//   let _def_flag: Bool
//   let _def_id: (Identifier | None)

//   new val create(src_info': SrcInfo, children': NodeSeq,
//     identifier': (Identifier | None), path': LiteralString,
//     def_flag': Bool, def_id': (Identifier | None))
//   =>
//     _src_info = src_info'
//     _children = children'
//     _identifier = identifier'
//     _path = path'
//     _def_flag = def_flag'
//     _def_id = def_id'

//   fun src_info(): SrcInfo => _src_info

//   fun info(): json.Item val =>
//     recover
//       let items =
//         [ as (String, json.Item):
//           ("node", "Using")
//           ("path", _path.info())
//         ]
//       match _identifier
//       | let id: Identifier =>
//         items.push(("id", id.info()))
//       end
//       match _def_id
//       | let id: Identifier =>
//         items.push(("ifdef", id.info()))
//         items.push(("ifdef_flag", _def_flag))
//       end
//       json.Object(items)
//     end

//   fun children(): NodeSeq => _children

//   fun identifier(): (Identifier | None) => _identifier
//   fun path(): LiteralString => _path
//   fun def_flag(): Bool => _def_flag
//   fun def_id(): (Identifier | None) => _def_id
