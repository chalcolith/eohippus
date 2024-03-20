use json = "../json"

class val ExpConsume is NodeData
  """A consume expression."""

  let cap: (NodeWith[Keyword] | None)
  let body: NodeWith[Expression]

  new val create(
    cap': (NodeWith[Keyword] | None),
    body': NodeWith[Expression])
  =>
    cap = cap'
    body = body'

  fun name(): String => "ExpConsume"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    ExpConsume(
      NodeChild.with_or_none[Keyword](cap, old_children, new_children)?,
      NodeChild.child_with[Expression](body, old_children, new_children)?)

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    match cap
    | let cap': NodeWith[Keyword] =>
      props.push(("cap", node.child_ref(cap')))
    end
    props.push(("body", node.child_ref(body)))
