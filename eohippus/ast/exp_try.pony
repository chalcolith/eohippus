use json = "../json"

class val ExpTry is NodeData
  let body: NodeWith[Expression]
  let else_block: (NodeWith[Expression] | None)

  new val create(
    body': NodeWith[Expression],
    else_block': (NodeWith[Expression] | None))
  =>
    body = body'
    else_block = else_block'

  fun name(): String => "ExpTry"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("body", body.get_json()))
    match else_block
    | let else_block': NodeWith[Expression] =>
      props.push(("else_block", else_block'.get_json()))
    end
