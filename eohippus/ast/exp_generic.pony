use json = "../json"

class val ExpGeneric is NodeData
  let lhs: NodeWith[Expression]
  let args: NodeWith[TypeArgs]

  new val create(lhs': NodeWith[Expression], args': NodeWith[TypeArgs]) =>
    lhs = lhs'
    args = args'

  fun name(): String => "ExpGeneric"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("lhs", lhs.get_json()))
    props.push(("args", args.get_json()))
