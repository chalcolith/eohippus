use json = "../json"

class val TypeArrow is NodeData
  """
    A top-level type (possibly with an arrow).
  """

  let lhs: Node
  let rhs: (NodeWith[TypeType] | None)

  new val create(lhs': Node, rhs': (NodeWith[TypeType] | None)) =>
    lhs = lhs'
    rhs = rhs'

  fun name(): String => "TypeArrow"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    TypeArrow(
      try updates(lhs)? else lhs end,
      _map_or_none[TypeType](rhs, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("lhs", node.child_ref(lhs)))
    match rhs
    | let rhs': NodeWith[TypeType] =>
      props.push(("rhs", node.child_ref(rhs')))
    end
