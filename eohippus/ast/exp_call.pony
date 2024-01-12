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

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    ExpCall(
      NodeChild.child_with[Expression](lhs, old_children, new_children)?,
      NodeChild.child_with[CallArgs](args, old_children, new_children)?,
      partial)

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("lhs", lhs.get_json()))
    props.push(("args", args.get_json()))
    if partial then
      props.push(("partial", partial))
    end
