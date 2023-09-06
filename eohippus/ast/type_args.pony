use json = "../json"

class val TypeArgs is NodeData
  let types: NodeSeqWith[TypeType]

  new val create(types': NodeSeqWith[TypeType]) =>
    types = types'

  fun name(): String => "TypeArgs"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("types", Nodes.get_json(types)))
