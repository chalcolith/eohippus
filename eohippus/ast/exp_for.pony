use json = "../json"

class val ExpFor is NodeData
  """
    A `for` loop.
  """

  let pattern: NodeWith[TuplePattern]
  let body: NodeWith[Expression]
  let else_block: (NodeWith[Expression] | None)

  new val create(
    pattern': NodeWith[TuplePattern],
    body': NodeWith[Expression],
    else_block': (NodeWith[Expression] | None))
  =>
    pattern = pattern'
    body = body'
    else_block = else_block'

  fun name(): String => "ExpFor"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    ExpFor(
      NodeChild.child_with[TuplePattern](pattern, old_children, new_children)?,
      NodeChild.child_with[Expression](body, old_children, new_children)?,
      NodeChild.with_or_none[Expression](else_block, old_children, new_children)?)

  fun add_json_props(
    props: Array[(String, json.Item)],
    lines_and_columns: (LineColumnMap | None) = None)
  =>
    props.push(("pattern", pattern.get_json(lines_and_columns)))
    props.push(("body", body.get_json(lines_and_columns)))
    match else_block
    | let else_block': NodeWith[Expression] =>
      props.push(("else_block", else_block'.get_json(lines_and_columns)))
    end
