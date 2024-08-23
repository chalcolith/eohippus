use json = "../json"

class val ExpRepeat is NodeData
  """A `repeat` expression."""

  let body: NodeWith[Expression]
  let condition: NodeWith[Expression]
  let else_block: (NodeWith[Expression] | None)

  new val create(
    body': NodeWith[Expression],
    condition': NodeWith[Expression],
    else_block': (NodeWith[Expression] | None))
  =>
    body = body'
    condition = condition'
    else_block = else_block'

  fun name(): String => "ExpRepeat"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    ExpRepeat(
      _map_with[Expression](body, updates),
      _map_with[Expression](condition, updates),
      _map_or_none[Expression](else_block, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("body", node.child_ref(body)))
    props.push(("condition", node.child_ref(condition)))
    match else_block
    | let else_block': NodeWith[Expression] =>
      props.push(("else_block", node.child_ref(else_block')))
    end

primitive ParseExpRepeat
  fun apply(obj: json.Object, children: NodeSeq): (ExpRepeat | String) =>
    let body =
      match ParseNode._get_child_with[Expression](
        obj,
        children,
        "body",
        "ExpRepeat.body must be an Expression")
      | let node: NodeWith[Expression] =>
        node
      | let err: String =>
        return err
      else
        return "ExpRepeat.body must be an Expression"
      end
    let condition =
      match ParseNode._get_child_with[Expression](
        obj,
        children,
        "condition",
        "ExpRepeat.condition must be an Expression")
      | let node: NodeWith[Expression] =>
        node
      | let err: String =>
        return err
      else
        return "ExpRepeat.condition must be an Expression"
      end
    let else_block =
      match ParseNode._get_child_with[Expression](
        obj,
        children,
        "else_block",
        "ExpRepeat.else_block must be an Expression",
        false)
      | let node: NodeWith[Expression] =>
        node
      | let err: String =>
        return err
      end
    ExpRepeat(body, condition, else_block)
