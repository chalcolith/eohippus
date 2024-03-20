use json = "../json"

class val ExpHash is NodeData
  """
    A compile-time expression.
  """

  let rhs: NodeWith[Expression]

  new val create(rhs': NodeWith[Expression]) =>
    rhs = rhs'

  fun name(): String => "ExpHash"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    ExpHash(NodeChild.child_with[Expression](rhs, old_children, new_children)?)

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("rhs", node.child_ref(rhs)))
