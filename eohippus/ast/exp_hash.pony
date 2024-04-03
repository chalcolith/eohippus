use json = "../json"

class val ExpHash is NodeData
  """
    A compile-time expression.
  """

  let rhs: NodeWith[Expression]

  new val create(rhs': NodeWith[Expression]) =>
    rhs = rhs'

  fun name(): String => "ExpHash"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    ExpHash(_map_with[Expression](rhs, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("rhs", node.child_ref(rhs)))
