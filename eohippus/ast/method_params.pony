use json = "../json"

class val MethodParams is NodeData
  """
    Method parameters (formal parameters).
  """

  let params: NodeSeqWith[MethodParam]

  new val create(params': NodeSeqWith[MethodParam]) =>
    params = params'

  fun name(): String => "MethodParams"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    MethodParams(
      NodeChild.seq_with[MethodParam](params, old_children, new_children)?)

  fun add_json_props(props: Array[(String, json.Item)]) =>
    if params.size() > 0 then
      props.push(("params", Nodes.get_json(params)))
    end

class val MethodParam is NodeData
  let identifier: NodeWith[Identifier]
  let constraint: (NodeWith[TypeType] | None)
  let initializer: (NodeWith[Expression] | None)

  new val create(
    identifier': NodeWith[Identifier],
    constraint': (NodeWith[TypeType] | None),
    initializer': (NodeWith[Expression] | None))
  =>
    identifier = identifier'
    constraint = constraint'
    initializer = initializer'

  fun name(): String => "MethodParam"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    MethodParam(
      NodeChild.child_with[Identifier](identifier, old_children, new_children)?,
      NodeChild.with_or_none[TypeType](constraint, old_children, new_children)?,
      NodeChild.with_or_none[Expression](initializer, old_children, new_children)?)

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("identifier", identifier.get_json()))
    match constraint
    | let constraint': NodeWith[TypeType] =>
      props.push(("constraint", constraint'.get_json()))
    end
    match initializer
    | let initializer': NodeWith[Expression] =>
      props.push(("initializer", initializer'.get_json()))
    end
