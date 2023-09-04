use json = "../json"

class val ExpHash is NodeData
  let rhs: NodeWith[Expression]

  new val create(rhs': NodeWith[Expression]) =>
    rhs = rhs'

  fun name(): String => "ExpHash"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("rhs", rhs.get_json()))
