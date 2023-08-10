use json = "../json"

class val DocString is NodeData
  let string: NodeWith[LiteralString]

  new val create(string': NodeWith[LiteralString]) =>
    string = string'

  fun name(): String => "DocString"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("string", string.get_json()))

// class val DocString is (Node & NodeWithChildren & NodeWithValue[String])
//   let _src_info: SrcInfo
//   let _children: NodeSeq
//   let _value: LiteralString

//   new val create(src_info': SrcInfo, children': NodeSeq,
//     value': LiteralString)
//   =>
//     _src_info = src_info'
//     _children = children'
//     _value = value'

//   fun src_info(): SrcInfo => _src_info
//   fun has_error(): Bool => value_error()
//   fun info(): json.Item val =>
//     recover
//       json.Object([
//         ("node", "Docstring")
//         ("string", _value.string())
//       ])
//     end
//   fun children(): NodeSeq => _children
//   fun value(): String => _value.value()
//   fun value_error(): Bool => _value.value_error()
