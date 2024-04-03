use json = "../json"

class val ExpLambda is NodeData
  """A lambda function."""

  let bare: Bool
  let this_cap: (NodeWith[Keyword] | None)
  let identifier: (NodeWith[Identifier] | None)
  let type_params: (NodeWith[TypeParams] | None)
  let params: NodeWith[MethodParams]
  let captures: (NodeWith[MethodParams] | None)
  let ret_type: (NodeWith[TypeType] | None)
  let partial: Bool
  let body: NodeWith[Expression]
  let ref_cap: (NodeWith[Keyword] | None)

  new val create(
    bare': Bool,
    this_cap': (NodeWith[Keyword] | None),
    identifier': (NodeWith[Identifier] | None),
    type_params': (NodeWith[TypeParams] | None),
    params': NodeWith[MethodParams],
    captures': (NodeWith[MethodParams] | None),
    ret_type': (NodeWith[TypeType] | None),
    partial': Bool,
    body': NodeWith[Expression],
    ref_cap': (NodeWith[Keyword] | None))
  =>
    bare = bare'
    this_cap = this_cap'
    identifier = identifier'
    type_params = type_params'
    params = params'
    captures = captures'
    ret_type = ret_type'
    partial = partial'
    body = body'
    ref_cap = ref_cap'

  fun name(): String => "ExpLambda"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    ExpLambda(
      bare,
      _map_or_none[Keyword](this_cap, updates),
      _map_or_none[Identifier](identifier, updates),
      _map_or_none[TypeParams](type_params, updates),
      _map_with[MethodParams](params, updates),
      _map_or_none[MethodParams](captures, updates),
      _map_or_none[TypeType](ret_type, updates),
      partial,
      _map_with[Expression](body, updates),
      _map_or_none[Keyword](ref_cap, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    if bare then
      props.push(("bare", bare))
    end
    match this_cap
    | let this_cap': NodeWith[Keyword] =>
      props.push(("this_cap", node.child_ref(this_cap')))
    end
    match identifier
    | let identifier': NodeWith[Identifier] =>
      props.push(("identifier", node.child_ref(identifier')))
    end
    match type_params
    | let type_params': NodeWith[TypeParams] =>
      props.push(("type_params", node.child_ref(type_params')))
    end
    props.push(("params", node.child_ref(params)))
    match captures
    | let captures': NodeWith[MethodParams] =>
      props.push(("captures", node.child_ref(captures')))
    end
    match ret_type
    | let ret_type': NodeWith[TypeType] =>
      props.push(("ret_type", node.child_ref(ret_type')))
    end
    if partial then
      props.push(("partial", partial))
    end
    props.push(("body", node.child_ref(body)))
    match ref_cap
    | let ref_cap': NodeWith[Keyword] =>
      props.push(("ref_cap", node.child_ref(ref_cap')))
    end
