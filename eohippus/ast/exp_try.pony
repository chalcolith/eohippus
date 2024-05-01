use json = "../json"

class val ExpTry is NodeData
  """A `try` block."""

  let body: NodeWith[Expression]
  let else_block: (NodeWith[Expression] | None)

  new val create(
    body': NodeWith[Expression],
    else_block': (NodeWith[Expression] | None))
  =>
    body = body'
    else_block = else_block'

  fun name(): String => "ExpTry"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    ExpTry(
      _map_with[Expression](body, updates),
      _map_or_none[Expression](else_block, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("body", node.child_ref(body)))
    match else_block
    | let else_block': NodeWith[Expression] =>
      props.push(("else_block", node.child_ref(else_block')))
    end

primitive ParseExpTry
  fun apply(obj: json.Object, children: NodeSeq): (ExpTry | String) =>
    let body =
      match ParseNode._get_child_with[Expression](
        obj,
        children,
        "body",
        "ExpTry.body must be an Expression")
      | let node: NodeWith[Expression] =>
        node
      | let err: String =>
        return err
      else
        return "ExpTry.body must be an Expression"
      end
    let else_block =
      match ParseNode._get_child_with[Expression](
        obj,
        children,
        "else_block",
        "ExpTry.else_block must be an Expression",
        false)
      | let node: NodeWith[Expression] =>
        node
      | let err: String =>
        return err
      end
    ExpTry(body, else_block)
