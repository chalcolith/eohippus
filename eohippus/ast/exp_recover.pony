use json = "../json"

class val ExpRecover is NodeData
  """A `recover` block."""

  let cap: (NodeWith[Keyword] | None)
  let body: NodeWith[Expression]

  new val create(
    cap': (NodeWith[Keyword] | None),
    body': NodeWith[Expression])
  =>
    cap = cap'
    body = body'

  fun name(): String => "ExpRecover"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    ExpRecover(
      NodeChild.with_or_none[Keyword](cap, old_children, new_children)?,
      NodeChild.child_with[Expression](body, old_children, new_children)?)

  fun add_json_props(props: Array[(String, json.Item)]) =>
    match cap
    | let cap': NodeWith[Keyword] =>
      props.push(("cap", cap'.get_json()))
    end
    props.push(("body", body.get_json()))
