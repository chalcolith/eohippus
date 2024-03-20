use json = "../json"

class val TypeParams is NodeData
  """Type parameters."""

  let params: NodeSeqWith[TypeParam]

  new val create(params': NodeSeqWith[TypeParam]) =>
    params = params'

  fun name(): String => "TypeParams"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    TypeParams(NodeChild.seq_with[TypeParam](params, old_children, new_children)?)

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    if params.size() > 0 then
      props.push(("params", node.child_refs(params)))
    end

class val TypeParam is NodeData
  let identifier: (NodeWith[Identifier] | None)
  let constraint: (NodeWith[TypeType] | None)
  let initializer: (NodeWith[TypeType] | None)

  new val create(
    identifier': (NodeWith[Identifier] | None),
    constraint': (NodeWith[TypeType] | None),
    initializer': (NodeWith[TypeType] | None))
  =>
    identifier = identifier'
    constraint = constraint'
    initializer = initializer'

  fun name(): String => "TypeParam"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    TypeParam(
      NodeChild.with_or_none[Identifier](identifier, old_children, new_children)?,
      NodeChild.with_or_none[TypeType](constraint, old_children, new_children)?,
      NodeChild.with_or_none[TypeType](initializer, old_children, new_children)?)

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    match identifier
    | let identifier': NodeWith[Identifier] =>
      props.push(("identifier", node.child_ref(identifier')))
    end
    match constraint
    | let constraint': NodeWith[TypeType] =>
      props.push(("constraint", node.child_ref(constraint')))
    end
    match initializer
    | let initializer': NodeWith[TypeType] =>
      props.push(("initializer", node.child_ref(initializer')))
    end
