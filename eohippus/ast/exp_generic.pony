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

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    ExpGeneric(
      NodeChild.child_with[Expression](lhs, old_children, new_children)?,
      NodeChild.child_with[TypeArgs](type_args, old_children, new_children)?)

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("lhs", lhs.get_json()))
    props.push(("type_args", type_args.get_json()))
