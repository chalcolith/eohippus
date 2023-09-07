use json = "../json"

class val ExpArray is NodeData
  let array_type: (NodeWith[TypeType] | None)
  let body: NodeWith[Expression]

  new val create(
    array_type': (NodeWith[TypeType] | None),
    body': NodeWith[Expression])
  =>
    array_type = array_type'
    body = body'

  fun name(): String => "ExpArray"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    match array_type
    | let array_type': NodeWith[TypeType] =>
      props.push(("type", array_type'.get_json()))
    end
    props.push(("body", body.get_json()))
