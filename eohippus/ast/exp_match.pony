use json = "../json"

class val ExpMatch is NodeData
  """A `match` expression."""
  let expression: NodeWith[Expression]
  let cases: NodeSeqWith[MatchCase]
  let else_block: (NodeWith[Expression] | None)

  new val create(
    expression': NodeWith[Expression],
    cases': NodeSeqWith[MatchCase],
    else_block': (NodeWith[Expression] | None))
  =>
    expression = expression'
    cases = cases'
    else_block = else_block'

  fun name(): String => "ExpMatch"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    ExpMatch(
      NodeChild.child_with[Expression](expression, old_children, new_children)?,
      NodeChild.seq_with[MatchCase](cases, old_children, new_children)?,
      NodeChild.with_or_none[Expression](else_block, old_children, new_children)?)

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("expression", node.child_ref(expression)))
    if cases.size() > 0 then
      props.push(("cases", node.child_refs(cases)))
    end
    match else_block
    | let else_block': NodeWith[Expression] =>
      props.push(("else_block", node.child_ref(else_block')))
    end

class val MatchCase is NodeData
  """A case in a `match` expression."""
  let pattern: NodeWith[Expression]
  let condition: (NodeWith[Expression] | None)
  let body: NodeWith[Expression]

  new val create(
    pattern': NodeWith[Expression],
    condition': (NodeWith[Expression] | None),
    body': NodeWith[Expression])
  =>
    pattern = pattern'
    condition = condition'
    body = body'

  fun name(): String => "MatchCase"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    MatchCase(
      NodeChild.child_with[Expression](pattern, old_children, new_children)?,
      NodeChild.with_or_none[Expression](condition, old_children, new_children)?,
      NodeChild.child_with[Expression](body, old_children, new_children)?)

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("pattern", node.child_ref(pattern)))
    match condition
    | let condition': NodeWith[Expression] =>
      props.push(("condition", node.child_ref(condition')))
    end
    props.push(("body", node.child_ref(body)))
