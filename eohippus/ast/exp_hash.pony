use json = "../json"

class val ExpHash is NodeData
  """
    A compile-time expression.
  """

  let rhs: NodeWith[Expression]

  new val create(rhs': NodeWith[Expression]) =>
    rhs = rhs'

  fun name(): String => "ExpHash"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    ExpHash(_map_with[Expression](rhs, updates))

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    props.push(("rhs", node.child_ref(rhs)))

primitive ParseExpHash
  fun apply(obj: json.Object, children: NodeSeq): (ExpHash | String) =>
    let rhs =
      match ParseNode._get_child_with[Expression](
        obj,
        children,
        "rhs",
        "ExpHash.rhs must be an Expression")
      | let node: NodeWith[Expression] =>
        node
      | let err: String =>
        return err
      else
        return "ExpHash.rhs must be an Expression"
      end
    ExpHash(rhs)
