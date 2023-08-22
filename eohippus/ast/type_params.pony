use json = "../json"

class val TypeParams is NodeData
  let params: NodeSeqWith[TypeParam]

  new create(params': NodeSeqWith[TypeParam]) =>
    params = params'

  fun name(): String => "TypeParams"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    if params.size() > 0 then
      props.push(("params", Nodes.get_json(params)))
    end

class val TypeParam is NodeData
  let identifier: NodeWith[Identifier]
  let constraint: (NodeWith[TypeType] | None)
  let initializer: (NodeWith[TypeType] | None)

  new create(
    identifier': NodeWith[Identifier],
    constraint': (NodeWith[TypeType] | None),
    initializer': (NodeWith[TypeType] | None))
  =>
    identifier = identifier'
    constraint = constraint'
    initializer = initializer'

  fun name(): String => "TypeParam"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("identifier", identifier.get_json()))
    match constraint
    | let constraint': NodeWith[TypeType] =>
      props.push(("constraint", constraint'.get_json()))
    end
    match initializer
    | let initializer': NodeWith[TypeType] =>
      props.push(("initializer", initializer'.get_json()))
    end
