use json = "../json"

class val ExpCall is NodeData
  let lhs: NodeWith[Expression]
  let args: NodeWith[CallArgs]
  let partial: Bool

  new val create(
    lhs': NodeWith[Expression],
    args': NodeWith[CallArgs],
    partial': Bool) =>
    lhs = lhs'
    args = args'
    partial = partial'

  fun name(): String => "ExpCall"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("lhs", lhs.get_json()))
    props.push(("args", args.get_json()))
    if partial then
      props.push(("partial", partial))
    end
