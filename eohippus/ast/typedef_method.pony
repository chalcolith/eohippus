use json = "../json"

class val TypedefMethod is NodeData
  let kind: NodeWith[Keyword]
  let cap: (NodeWith[Keyword] | None)
  let raw: Bool
  let identifier: NodeWith[Identifier]
  let type_params: (NodeWith[TypeParams] | None)
  let params: (NodeWith[MethodParams] | None)
  let return_type: (NodeWith[TypeType] | None)
  let partial: Bool
  let body: (NodeWith[Expression] | None)

  new val create(
    kind': NodeWith[Keyword],
    cap': (NodeWith[Keyword] | None),
    raw': Bool,
    identifier': NodeWith[Identifier],
    type_params': (NodeWith[TypeParams] | None),
    params': (NodeWith[MethodParams] | None),
    return_type': (NodeWith[TypeType] | None),
    partial': Bool,
    body': (NodeWith[Expression] | None))
  =>
    kind = kind'
    cap = cap'
    raw = raw'
    identifier = identifier'
    type_params = type_params'
    params = params'
    return_type = return_type'
    partial = partial'
    body = body'

  fun name(): String => "TypedefMethod"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    TypedefMethod(
      _child_with[Keyword](kind, old_children, new_children)?,
      _child_with_or_none[Keyword](cap, old_children, new_children)?,
      raw,
      _child_with[Identifier](identifier, old_children, new_children)?,
      _child_with_or_none[TypeParams](type_params, old_children, new_children)?,
      _child_with_or_none[MethodParams](params, old_children, new_children)?,
      _child_with_or_none[TypeType](return_type, old_children, new_children)?,
      partial,
      _child_with_or_none[Expression](body, old_children, new_children)?)

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("kind", kind.get_json()))
    match cap
    | let cap': NodeWith[Keyword] =>
      props.push(("cap", cap'.get_json()))
    end
    if raw then
      props.push(("raw", raw))
    end
    props.push(("identifier", identifier.get_json()))
    match type_params
    | let type_params': NodeWith[TypeParams] =>
      if type_params'.data().params.size() > 0 then
        props.push(("type_params", type_params'.get_json()))
      end
    end
    match params
    | let params': NodeWith[MethodParams] =>
      if params'.data().params.size() > 0 then
        props.push(("params", params'.get_json()))
      end
    end
    match return_type
    | let return_type': NodeWith[TypeType] =>
      props.push(("return_type", return_type'.get_json()))
    end
    if partial then
      props.push(("partial", partial))
    end
    match body
    | let body': NodeWith[Expression] =>
      props.push(("body", body'.get_json()))
    end
