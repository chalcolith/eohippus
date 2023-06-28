use json = "../json"

class val TypeArgs is (Node & NodeWithChildren)
  let _src_info: SrcInfo
  let _children: NodeSeq
  let _args: NodeSeq[TypeArg]

  new val create(
    src_info': SrcInfo,
    children': NodeSeq,
    args': NodeSeq[TypeArg])
  =>
    _src_info = src_info'
    _children = children'
    _args = args'

  fun src_info(): SrcInfo => _src_info

  fun info(): json.Item val =>
    recover
      let items =
        [ as (String, json.Item):
          ("node", "TypeArgs")
        ]
      let args' = _info_seq(_args)
      if args'.size() > 0 then
        items.push(("args", args'))
      end
      json.Object(items)
    end

  fun children(): NodeSeq => _children

  fun args(): NodeSeq => _args

class val TypeArg is (Node & NodeWithChildren)
  let _src_info: SrcInfo
  let _children: NodeSeq
  let _arg: Node

  new val create(src_info': SrcInfo, children': NodeSeq, arg': Node) =>
    _src_info = src_info'
    _children = children'
    _arg = arg'

  fun src_info(): SrcInfo => _src_info

  fun info(): json.Item val =>
    recover
      json.Object([
        ("node", "TypeArg")
        ("arg", _arg.info())
      ])
    end

  fun children(): NodeSeq => _children

  fun arg(): Node => _arg
