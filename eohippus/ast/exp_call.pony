use json = "../json"

class val ExpCall is NodeData
  let lhs: NodeWith[Expression]
  let args: NodeWith[CallArgs]

  new val create(lhs': NodeWith[Expression], args': NodeWith[CallArgs]) =>
    lhs = lhs'
    args = args'

  fun name(): String => "ExpCall"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("lhs", lhs.get_json()))
    props.push(("args", args.get_json()))
