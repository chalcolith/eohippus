use json = "../json"

class val ExpFfi is NodeData
  """
    An FFI call.
  """

  let identifier: (NodeWith[Identifier] | NodeWith[LiteralString])
  let type_args: (NodeWith[TypeArgs] | None)
  let call_args: NodeWith[CallArgs]
  let partial: Bool

  new val create(
    identifier': (NodeWith[Identifier] | NodeWith[LiteralString]),
    type_args': (NodeWith[TypeArgs] | None),
    call_args': NodeWith[CallArgs],
    partial': Bool)
  =>
    identifier = identifier'
    type_args = type_args'
    call_args = call_args'
    partial = partial'

  fun name(): String => "ExpFfi"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    ExpFfi(
      NodeChild(identifier, old_children, new_children)?
        as (NodeWith[Identifier] | NodeWith[LiteralString]),
      NodeChild.with_or_none[TypeArgs](type_args, old_children, new_children)?,
      NodeChild.child_with[CallArgs](call_args, old_children, new_children)?,
      partial)

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("identifier", node.child_ref(identifier)))
    match type_args
    | let type_args': NodeWith[TypeArgs] =>
      props.push(("type_args", node.child_ref(type_args')))
    end
    props.push(("call_args", node.child_ref(call_args)))
    if partial then
      props.push(("partial", partial))
    end
