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

  fun val clone(updates: ChildUpdateMap): ExpConsume =>
    ExpConsume(
      _map_or_none[Keyword](cap, updates),
      _map_with[Expression](body, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    match cap
    | let cap': NodeWith[Keyword] =>
      props.push(("cap", node.child_ref(cap')))
    end
    props.push(("body", node.child_ref(body)))
