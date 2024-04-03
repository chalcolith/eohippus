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

  fun val clone(updates: ChildUpdateMap): ExpMatch =>
    ExpMatch(
      _map_with[Expression](expression, updates),
      _map[MatchCase](cases, updates),
      _map_or_none[Expression](else_block, updates))

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

  fun val clone(updates: ChildUpdateMap): MatchCase =>
    MatchCase(
      _map_with[Expression](pattern, updates),
      _map_or_none[Expression](condition, updates),
      _map_with[Expression](body, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("pattern", node.child_ref(pattern)))
    match condition
    | let condition': NodeWith[Expression] =>
      props.push(("condition", node.child_ref(condition')))
    end
    props.push(("body", node.child_ref(body)))
