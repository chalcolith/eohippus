use json = "../json"

class val ExpGeneric is NodeData
  """
    An expression with type arguments.
  """

  let lhs: NodeWith[Expression]
  let type_args: NodeWith[TypeArgs]

  new val create(lhs': NodeWith[Expression], type_args': NodeWith[TypeArgs]) =>
    lhs = lhs'
    type_args = type_args'

  fun name(): String => "ExpGeneric"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    ExpGeneric(
      _map_with[Expression](lhs, updates),
      _map_with[TypeArgs](type_args, updates))

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    props.push(("lhs", node.child_ref(lhs)))
    props.push(("type_args", node.child_ref(type_args)))

primitive ParseExpGeneric
  fun apply(obj: json.Object val, children: NodeSeq): (ExpGeneric | String) =>
    let lhs =
      match ParseNode._get_child_with[Expression](
        obj,
        children,
        "lhs",
        "ExpGeneric.lhs must be an Expression")
      | let node: NodeWith[Expression] =>
        node
      | let err: String =>
        return err
      else
        return "ExpGeneric.lhs must be an Expression"
      end
    let type_args =
      match ParseNode._get_child_with[TypeArgs](
        obj,
        children,
        "type_args",
        "ExpGeneric.type_args must be a TypeArgs")
      | let node: NodeWith[TypeArgs] =>
        node
      | let err: String =>
        return err
      else
        return "ExpGeneric.type_args must be a TypeArgs"
      end
    ExpGeneric(lhs, type_args)
