use json = "../json"

class val TypedefAlias is NodeData
  let identifier: NodeWith[Identifier]
  let type_params: (NodeWith[TypeParams] | None)
  let type_type: NodeWith[TypeType]

  new val create(
    identifier': NodeWith[Identifier],
    type_params': (NodeWith[TypeParams] | None),
    type_type': NodeWith[TypeType])
  =>
    identifier = identifier'
    type_params = type_params'
    type_type = type_type'

  fun name(): String => "TypedefAlias"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("identifier", identifier.get_json()))
    match type_params
    | let type_params': NodeWith[TypeParams] =>
      props.push(("type_params", type_params'.get_json()))
    end
    props.push(("type", type_type.get_json()))
