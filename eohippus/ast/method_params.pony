use json = "../json"

class val MethodParams is NodeData
  """
    Method parameters (formal parameters).
  """

  let params: NodeSeqWith[MethodParam]

  new val create(params': NodeSeqWith[MethodParam]) =>
    params = params'

  fun name(): String => "MethodParams"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    MethodParams(_map[MethodParam](params, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    if params.size() > 0 then
      props.push(("params", node.child_refs(params)))
    end

class val MethodParam is NodeData
  let identifier: NodeWith[Identifier]
  let constraint: (NodeWith[TypeType] | None)
  let initializer: (NodeWith[Expression] | None)

  new val create(
    identifier': NodeWith[Identifier],
    constraint': (NodeWith[TypeType] | None),
    initializer': (NodeWith[Expression] | None))
  =>
    identifier = identifier'
    constraint = constraint'
    initializer = initializer'

  fun name(): String => "MethodParam"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    MethodParam(
      _map_with[Identifier](identifier, updates),
      _map_or_none[TypeType](constraint, updates),
      _map_or_none[Expression](initializer, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("identifier", node.child_ref(identifier)))
    match constraint
    | let constraint': NodeWith[TypeType] =>
      props.push(("constraint", node.child_ref(constraint')))
    end
    match initializer
    | let initializer': NodeWith[Expression] =>
      props.push(("initializer", node.child_ref(initializer')))
    end
