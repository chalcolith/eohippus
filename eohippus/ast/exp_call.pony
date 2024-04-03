use json = "../json"

class val ExpCall is NodeData
  """
    A method call.
    - `lhs`: the callee.
    - `args`: arguments.
    - `partial`: whether or not the call is partial.
  """

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

  fun val clone(updates: ChildUpdateMap): NodeData =>
    ExpCall(
      _map_with[Expression](lhs, updates),
      _map_with[CallArgs](args, updates),
      partial)

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("lhs", node.child_ref(lhs)))
    props.push(("args", node.child_ref(args)))
    if partial then
      props.push(("partial", partial))
    end
