use json = "../json"

class val ExpFor is NodeData
  let ids: NodeSeqWith[Identifier]
  let body: NodeWith[Expression]
  let else_block: (NodeWith[Expression] | None)

  new val create(
    ids': NodeSeqWith[Identifier],
    body': NodeWith[Expression],
    else_block': (NodeWith[Expression] | None))
  =>
    ids = ids'
    body = body'
    else_block = else_block'

  fun name(): String => "ExpFor"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    if ids.size() > 0 then
      props.push(("ids", Nodes.get_json(ids)))
    end
    props.push(("body", body.get_json()))
    match else_block
    | let else_block': NodeWith[Expression] =>
      props.push(("else_block", else_block'.get_json()))
    end
