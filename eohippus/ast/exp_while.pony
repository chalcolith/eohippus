use json = "../json"

class val ExpWhile is NodeData
  """A `while` loop."""

  let condition: NodeWith[Expression]
  let body: NodeWith[Expression]
  let else_block: (NodeWith[Expression] | None)

  new val create(
    condition': NodeWith[Expression],
    body': NodeWith[Expression],
    else_block': (NodeWith[Expression] | None))
  =>
    condition = condition'
    body = body'
    else_block = else_block'

  fun name(): String => "ExpWhile"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    ExpWhile(
      _map_with[Expression](condition, updates),
      _map_with[Expression](body, updates),
      _map_or_none[Expression](else_block, updates))

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    props.push(("condition", node.child_ref(condition)))
    props.push(("body", node.child_ref(body)))
    match else_block
    | let else_block': NodeWith[Expression] =>
      props.push(("else_block", node.child_ref(else_block')))
    end

primitive ParseExpWhile
  fun apply(obj: json.Object, children: NodeSeq): (ExpWhile | String) =>
    let condition =
      match ParseNode._get_child_with[Expression](
        obj,
        children,
        "condition",
        "ExpWhile.condition must be an Expression")
      | let node: NodeWith[Expression] =>
        node
      | let err: String =>
        return err
      else
        return "ExpWhile.condition must be an Expression"
      end
    let body =
      match ParseNode._get_child_with[Expression](
        obj,
        children,
        "body",
        "ExpWhile.body must be an Expression")
      | let node: NodeWith[Expression] =>
        node
      | let err: String =>
        return err
      else
        return "ExpWhile.body must be an Expression"
      end
    let else_block =
      match ParseNode._get_child_with[Expression](
        obj,
        children,
        "else_block",
        "ExpWhile.else_block must be an Expression",
        false)
      | let node: NodeWith[Expression] =>
        node
      | let err: String =>
        return err
      end
    ExpWhile(condition, body, else_block)
