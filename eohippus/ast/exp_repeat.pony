use json = "../json"

class val ExpRepeat is NodeData
  """A `repeat` expression."""

  let body: NodeWith[Expression]
  let condition: NodeWith[Expression]
  let else_block: (NodeWith[Expression] | None)

  new val create(
    body': NodeWith[Expression],
    condition': NodeWith[Expression],
    else_block': (NodeWith[Expression] | None))
  =>
    body = body'
    condition = condition'
    else_block = else_block'

  fun name(): String => "ExpRepeat"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    ExpRepeat(
      _map_with[Expression](body, updates),
      _map_with[Expression](condition, updates),
      _map_or_none[Expression](else_block, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("body", node.child_ref(body)))
    props.push(("condition", node.child_ref(condition)))
    match else_block
    | let else_block': NodeWith[Expression] =>
      props.push(("else_block", node.child_ref(else_block')))
    end
