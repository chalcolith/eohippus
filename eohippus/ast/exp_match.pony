use json = "../json"

class val ExpMatch is NodeData
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

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("expression", expression.get_json()))
    if cases.size() > 0 then
      props.push(("cases", Nodes.get_json(cases)))
    end
    match else_block
    | let else_block': NodeWith[Expression] =>
      props.push(("else_block", else_block'.get_json()))
    end

class val MatchCase is NodeData
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

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("pattern", pattern.get_json()))
    match condition
    | let condition': NodeWith[Expression] =>
      props.push(("condition", condition'.get_json()))
    end
    props.push(("body", body.get_json()))
