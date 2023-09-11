use json = "../json"

class val ExpWhile is NodeData
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

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("condition", condition.get_json()))
    props.push(("body", body.get_json()))
    match else_block
    | let else_block': NodeWith[Expression] =>
      props.push(("else_block", else_block'.get_json()))
    end
