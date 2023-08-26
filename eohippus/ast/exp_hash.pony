use json = "../json"

class val ExpHash is NodeData
  let rhs: Node

  new val create(rhs': Node) =>
    rhs = rhs'

  fun name(): String => "ExpHash"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("rhs", rhs.get_json()))
