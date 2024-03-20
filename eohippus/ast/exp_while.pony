use json = "../json"

class val ExpWhile is NodeData
  """A `while` loop."""

  let condition: NodeWith[Expression]
  let body: NodeWith[Expression]
  let else_block: (NodeWith[Expression] | None)

  new val create(
    condition': NodeWith[Expression],
    body': NodeWith[Expression],
    else_block': (NodeWith[Expression] | None))
  =>
    condition = condition'
    body = body'
    else_block = else_block'

  fun name(): String => "ExpWhile"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    ExpWhile(
      NodeChild.child_with[Expression](condition, old_children, new_children)?,
      NodeChild.child_with[Expression](body, old_children, new_children)?,
      NodeChild.with_or_none[Expression](else_block, old_children, new_children)?)

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("condition", node.child_ref(condition)))
    props.push(("body", node.child_ref(body)))
    match else_block
    | let else_block': NodeWith[Expression] =>
      props.push(("else_block", node.child_ref(else_block')))
    end
