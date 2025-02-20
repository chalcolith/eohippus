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
    partial': Bool)
  =>
    lhs = lhs'
    args = args'
    partial = partial'

  fun name(): String => "ExpCall"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    ExpCall(
      _map_with[Expression](lhs, updates),
      _map_with[CallArgs](args, updates),
      partial)

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    props.push(("lhs", node.child_ref(lhs)))
    props.push(("args", node.child_ref(args)))
    if partial then
      props.push(("partial", partial))
    end

primitive ParseExpCall
  fun apply(obj: json.Object val, children: NodeSeq): (ExpCall | String) =>
    let lhs =
      match ParseNode._get_child_with[Expression](
        obj,
        children,
        "lhs",
        "ExpCall.lhs must be an Expression")
      | let node: NodeWith[Expression] =>
        node
      | let err: String =>
        return err
      else
        return "ExpCall.lhs must be an Expression"
      end
    let args =
      match ParseNode._get_child_with[CallArgs](
        obj,
        children,
        "args",
        "ExpCall.args must be a CallArgs")
      | let node: NodeWith[CallArgs] =>
        node
      | let err: String =>
        return err
      else
        return "ExpCall.args must be a CallArgs"
      end
    let partial =
      match try obj("partial")? end
      | let bool: Bool =>
        bool
      | let item: json.Item =>
        return "ExpCall.partial must be a boolean"
      else
        false
      end
    ExpCall(lhs, args, partial)
