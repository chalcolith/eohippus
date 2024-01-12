use json = "../json"

class val TypeParams is NodeData
  let params: NodeSeqWith[TypeParam]

  new val create(params': NodeSeqWith[TypeParam]) =>
    params = params'

  fun name(): String => "TypeParams"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    TypeParams(NodeChild.seq_with[TypeParam](params, old_children, new_children)?)

  fun add_json_props(props: Array[(String, json.Item)]) =>
    if params.size() > 0 then
      props.push(("params", Nodes.get_json(params)))
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

  fun add_json_props(props: Array[(String, json.Item)]) =>
    match identifier
    | let identifier': NodeWith[Identifier] =>
      props.push(("identifier", identifier'.get_json()))
    end
    match constraint
    | let constraint': NodeWith[TypeType] =>
      props.push(("constraint", constraint'.get_json()))
    end
    match initializer
    | let initializer': NodeWith[TypeType] =>
      props.push(("initializer", initializer'.get_json()))
    end
