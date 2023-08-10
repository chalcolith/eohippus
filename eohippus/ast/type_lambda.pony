use "itertools"

use json = "../json"

// class val TypeLambda is (Node & NodeWithChildren)
//   let _src_info: SrcInfo
//   let _children: NodeSeq

//   let _bare: Bool
//   let _cap: (Node | None)
//   let _name: (Node | None)
//   let _tparams: NodeSeq
//   let _ptypes: NodeSeq
//   let _rtype: (Node | None)
//   let _partial: Bool
//   let _rcap: (Node | None)
//   let _reph: (Node | None)

//   new val create(
//     src_info': SrcInfo,
//     children': NodeSeq,
//     bare': Bool,
//     cap': (Node | None),
//     name': (Node | None),
//     tparams': NodeSeq,
//     ptypes': NodeSeq,
//     rtype': (Node | None),
//     partial': Bool,
//     rcap': (Node | None),
//     reph': (Node | None))
//   =>
//     _src_info = src_info'
//     _children = children'
//     _bare = bare'
//     _cap = cap'
//     _name = name'
//     _tparams = tparams'
//     _ptypes = ptypes'
//     _rtype = rtype'
//     _partial = partial'
//     _rcap = rcap'
//     _reph = reph'

//   fun src_info(): SrcInfo => _src_info

//   fun info(): json.Item val =>
//     recover val
//       let items =
//         [ as (String, json.Item val):
//           ("node", "TypeLambda")
//           ("bare", _bare)
//           ("partial", _partial)
//         ]
//       match _cap
//       | let cap': Node =>
//         items.push(("cap", cap'.info()))
//       end
//       match _name
//       | let name': Node =>
//         items.push(("name", name'.info()))
//       end
//       let tparams' = _info_seq(_tparams)
//       if tparams'.size() > 0 then
//         items.push(("tparams", tparams'))
//       end
//       let ptypes' = _info_seq(_ptypes)
//       if ptypes'.size() > 0 then
//         items.push(("ptypes", ptypes'))
//       end
//       match _rtype
//       | let rtype': Node =>
//         items.push(("rtype", rtype'.info()))
//       end
//       match _rcap
//       | let rcap': Node =>
//         items.push(("rcap", rcap'.info()))
//       end
//       match _reph
//       | let reph': Node =>
//         items.push(("reph", reph'.info()))
//       end
//       json.Object(items)
//     end

//   fun children(): NodeSeq => _children

//   fun bare(): Bool => _bare

//   fun cap(): (Node | None) => _cap

//   fun name(): (Node | None) => _name

//   fun tparams(): NodeSeq => _tparams

//   fun ptypes(): NodeSeq => _ptypes

//   fun rtype(): (Node | None) => _rtype

//   fun partial(): Bool => _partial

//   fun rcap(): (Node | None) => _rcap

//   fun reph(): (Node | None) => _reph
