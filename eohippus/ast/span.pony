use json = "../json"

class val Span is NodeData
  new create() =>
    None

  fun name(): String => "Span"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    None

// class val Span is Node
//   let _src_info: SrcInfo

//   new val create(src_info': SrcInfo) =>
//     _src_info = src_info'

//   fun src_info(): SrcInfo => _src_info

//   fun has_error(): Bool => false

//   fun info(): json.Item val =>
//     recover
//       json.Object([
//         ("node", "Span")
//         ("string", _src_info.literal_source())
//       ])
//     end

//   fun literal_source(): String => _src_info.literal_source()
