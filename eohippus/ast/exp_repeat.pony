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

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    ExpRepeat(
      NodeChild.child_with[Expression](body, old_children, new_children)?,
      NodeChild.child_with[Expression](condition, old_children, new_children)?,
      NodeChild.with_or_none[Expression](else_block, old_children, new_children)?)

  fun add_json_props(
    props: Array[(String, json.Item)],
    lines_and_columns: (LineColumnMap | None) = None)
  =>
    props.push(("body", body.get_json(lines_and_columns)))
    props.push(("condition", condition.get_json(lines_and_columns)))
    match else_block
    | let else_block': NodeWith[Expression] =>
      props.push(("else_block", else_block'.get_json(lines_and_columns)))
    end
