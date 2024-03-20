use json = "../json"

class val ExpWith is NodeData
  """A `with` block."""

  let elements: NodeSeqWith[WithElement]
  let body: NodeWith[Expression]

  new val create(
    elements': NodeSeqWith[WithElement],
    body': NodeWith[Expression])
  =>
    elements = elements'
    body = body'

  fun name(): String => "ExpWith"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    ExpWith(
      NodeChild.seq_with[WithElement](elements, old_children, new_children)?,
      NodeChild.child_with[Expression](body, old_children, new_children)?)

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    if elements.size() > 0 then
      props.push(("elements", node.child_refs(elements)))
    end
    props.push(("body", node.child_ref(body)))

class val WithElement is NodeData
  """An arm of a `with` expression."""

  let pattern: NodeWith[TuplePattern]
  let body: NodeWith[Expression]

  new val create(
    pattern': NodeWith[TuplePattern],
    body': NodeWith[Expression])
  =>
    pattern = pattern'
    body = body'

  fun name(): String => "WithElement"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    WithElement(
      NodeChild.child_with[TuplePattern](pattern, old_children, new_children)?,
      NodeChild.child_with[Expression](body, old_children, new_children)?)

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("pattern", node.child_ref(pattern)))
    props.push(("body", node.child_ref(body)))
