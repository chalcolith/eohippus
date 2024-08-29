use json = "../json"

class val TypedefMethod is NodeData
  """A method definition."""

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

  fun val clone(updates: ChildUpdateMap): NodeData =>
    TypedefMethod(
      _map_with[Keyword](kind, updates),
      _map_or_none[Keyword](cap, updates),
      raw,
      _map_with[Identifier](identifier, updates),
      _map_or_none[TypeParams](type_params, updates),
      _map_or_none[MethodParams](params, updates),
      _map_or_none[TypeType](return_type, updates),
      partial,
      _map_or_none[Expression](body, updates))

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    props.push(("kind", node.child_ref(kind)))
    match cap
    | let cap': NodeWith[Keyword] =>
      props.push(("cap", node.child_ref(cap')))
    end
    if raw then
      props.push(("raw", raw))
    end
    props.push(("identifier", node.child_ref(identifier)))
    match type_params
    | let type_params': NodeWith[TypeParams] =>
      if type_params'.data().params.size() > 0 then
        props.push(("type_params", node.child_ref(type_params')))
      end
    end
    match params
    | let params': NodeWith[MethodParams] =>
      if params'.data().params.size() > 0 then
        props.push(("params", node.child_ref(params')))
      end
    end
    match return_type
    | let return_type': NodeWith[TypeType] =>
      props.push(("return_type", node.child_ref(return_type')))
    end
    if partial then
      props.push(("partial", partial))
    end
    match body
    | let body': NodeWith[Expression] =>
      props.push(("body", node.child_ref(body')))
    end

primitive ParseTypedefMethod
  fun apply(obj: json.Object, children: NodeSeq): (TypedefMethod | String) =>
    let kind =
      match ParseNode._get_child_with[Keyword](
        obj,
        children,
        "kind",
        "TypedefMethod.kind must be a Keyword")
      | let node: NodeWith[Keyword] =>
        node
      | let err: String =>
        return err
      else
        return "TypedefMethod.kind must be a Keyword"
      end
    let cap =
      match ParseNode._get_child_with[Keyword](
        obj,
        children,
        "cap",
        "TypedefMethod.cap must be a Keyword",
        false)
      | let node: NodeWith[Keyword] =>
        node
      | let err: String =>
        return err
      end
    let raw =
      match try obj("raw")? end
      | let bool: Bool =>
        bool
      | let item: json.Item =>
        return "TypedefMethod.raw must be a boolean"
      else
        false
      end
    let identifier =
      match ParseNode._get_child_with[Identifier](
        obj,
        children,
        "identifier",
        "TypedefMethod.identifier must be an Identifier")
      | let node: NodeWith[Identifier] =>
        node
      | let err: String =>
        return err
      else
        return "TypedefMethod.identifier must be an Identifier"
      end
    let type_params =
      match ParseNode._get_child_with[TypeParams](
        obj,
        children,
        "type_params",
        "TypedefMethod.type_params must be a TypeParams",
        false)
      | let node: NodeWith[TypeParams] =>
        node
      | let err: String =>
        return err
      end
    let params =
      match ParseNode._get_child_with[MethodParams](
        obj,
        children,
        "params",
        "TypedefMethod.params must be a MethodParams",
        false)
      | let node: NodeWith[MethodParams] =>
        node
      | let err: String =>
        return err
      end
    let return_type =
      match ParseNode._get_child_with[TypeType](
        obj,
        children,
        "return_type",
        "TypedefMethod.return_type must be a TypeType",
        false)
      | let node: NodeWith[TypeType] =>
        node
      | let err: String =>
        return err
      end
    let partial =
      match try obj("partial")? end
      | let bool: Bool =>
        bool
      | let item: json.Item =>
        return "TypedefMethod.partial must be a boolean"
      else
        false
      end
    let body =
      match ParseNode._get_child_with[Expression](
        obj,
        children,
        "body",
        "TypedefMethod.body must be an Expression",
        false)
      | let node: NodeWith[Expression] =>
        node
      | let err: String =>
        return err
      end
    TypedefMethod(
      kind,
      cap,
      raw,
      identifier,
      type_params,
      params,
      return_type,
      partial,
      body)
