use json = "../json"

class val ExpFor is NodeData
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

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("pattern", pattern.get_json()))
    props.push(("body", body.get_json()))
    match else_block
    | let else_block': NodeWith[Expression] =>
      props.push(("else_block", else_block'.get_json()))
    end
