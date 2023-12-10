use json = "../json"

class val ExpLambda is NodeData
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

  fun add_json_props(props: Array[(String, json.Item)]) =>
    if bare then
      props.push(("bare", bare))
    end
    match this_cap
    | let this_cap': NodeWith[Keyword] =>
      props.push(("this_cap", this_cap'.get_json()))
    end
    match identifier
    | let identifier': NodeWith[Identifier] =>
      props.push(("identifier", identifier'.get_json()))
    end
    match type_params
    | let type_params': NodeWith[TypeParams] =>
      props.push(("type_params", type_params'.get_json()))
    end
    props.push(("params", params.get_json()))
    match captures
    | let captures': NodeWith[MethodParams] =>
      props.push(("captures", captures'.get_json()))
    end
    match ret_type
    | let ret_type': NodeWith[TypeType] =>
      props.push(("ret_type", ret_type'.get_json()))
    end
    if partial then
      props.push(("partial", partial))
    end
    props.push(("body", body.get_json()))
    match ref_cap
    | let ref_cap': NodeWith[Keyword] =>
      props.push(("ref_cap", ref_cap'.get_json()))
    end
