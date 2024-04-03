use json = "../json"

class val ExpGeneric is NodeData
  """
    An expression with type arguments.
  """

  let lhs: NodeWith[Expression]
  let type_args: NodeWith[TypeArgs]

  new val create(lhs': NodeWith[Expression], type_args': NodeWith[TypeArgs]) =>
    lhs = lhs'
    type_args = type_args'

  fun name(): String => "ExpGeneric"

  fun val clone(updates: ChildUpdateMap): ExpGeneric =>
    ExpGeneric(
      _map_with[Expression](lhs, updates),
      _map_with[TypeArgs](type_args, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("lhs", node.child_ref(lhs)))
    props.push(("type_args", node.child_ref(type_args)))
