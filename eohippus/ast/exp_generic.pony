use json = "../json"

class val ExpGeneric is NodeData
  let lhs: NodeWith[Expression]
  let type_args: NodeWith[TypeArgs]

  new val create(lhs': NodeWith[Expression], type_args': NodeWith[TypeArgs]) =>
    lhs = lhs'
    type_args = type_args'

  fun name(): String => "ExpGeneric"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("lhs", lhs.get_json()))
    props.push(("type_args", type_args.get_json()))
