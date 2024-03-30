use json = "../json"

class val ExpFor is NodeData
  """
    A `for` loop.
  """

  let pattern: NodeWith[TuplePattern]
  let sequence: NodeWith[Expression]
  let body: NodeWith[Expression]
  let else_block: (NodeWith[Expression] | None)

  new val create(
    pattern': NodeWith[TuplePattern],
    sequence': NodeWith[Expression],
    body': NodeWith[Expression],
    else_block': (NodeWith[Expression] | None))
  =>
    pattern = pattern'
    sequence = sequence'
    body = body'
    else_block = else_block'

  fun name(): String => "ExpFor"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    ExpFor(
      NodeChild.child_with[TuplePattern](pattern, old_children, new_children)?,
      NodeChild.child_with[Expression](sequence, old_children, new_children)?,
      NodeChild.child_with[Expression](body, old_children, new_children)?,
      NodeChild.with_or_none[Expression](
        else_block, old_children, new_children)?)

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("pattern", node.child_ref(pattern)))
    props.push(("sequence", node.child_ref(sequence)))
    props.push(("body", node.child_ref(body)))
    match else_block
    | let else_block': NodeWith[Expression] =>
      props.push(("else_block", node.child_ref(else_block')))
    end
