use json = "../json"

class val ExpOperation is NodeData
  let lhs: (Node | None)
  let op: (NodeWith[Keyword] | NodeWith[Token])
  let rhs: Node

  new val create(
    lhs': (Node | None),
    op': (NodeWith[Keyword] | NodeWith[Token]),
    rhs': Node)
  =>
    lhs = lhs'
    op = op'
    rhs = rhs'

  fun name(): String => "ExpOperation"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    match lhs
    | let lhs': Node =>
      props.push(("lhs", lhs'.get_json()))
    end
    props.push(("op", op.get_json()))
    props.push(("rhs", rhs.get_json()))
