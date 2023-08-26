use json = "../json"

class val TypeArgs is NodeData
  let args: NodeSeqWith[TypeType]

  new val create(args': NodeSeqWith[TypeType]) =>
    args = args'

  fun name(): String => "TypeArgs"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("args", Nodes.get_json(args)))
