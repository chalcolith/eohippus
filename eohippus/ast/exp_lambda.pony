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

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
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

primitive ParseExpLambda
  fun apply(obj: json.Object, children: NodeSeq): (ExpLambda | String) =>
    let bare =
      match try obj("bare")? end
      | let bool: Bool =>
        bool
      | let item: json.Item =>
        return "ExpLambda.bare must be a boolean"
      else
        false
      end
    let this_cap =
      match ParseNode._get_child_with[Keyword](
        obj,
        children,
        "this_cap",
        "ExpLambda.this_cap must be a Keyword",
        false)
      | let node: NodeWith[Keyword] =>
        node
      | let err: String =>
        return err
      end
    let identifier =
      match ParseNode._get_child_with[Identifier](
        obj,
        children,
        "identifier",
        "ExpLambda.identifier must be an Identifier",
        false)
      | let node: NodeWith[Identifier] =>
        node
      | let err: String =>
        return err
      end
    let type_params =
      match ParseNode._get_child_with[TypeParams](
        obj,
        children,
        "type_params",
        "ExpLambda.type_params must be a TypeParams",
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
        "ExpLambda.params must be a MethodParams")
      | let node: NodeWith[MethodParams] =>
        node
      | let err: String =>
        return err
      else
        return "ExpLambda.params must be a MethodParams"
      end
    let captures =
      match ParseNode._get_child_with[MethodParams](
        obj,
        children,
        "captures",
        "ExpLambda.captures must be a MethodParams",
        false)
      | let node: NodeWith[MethodParams] =>
        node
      | let err: String =>
        return err
      end
    let ret_type =
      match ParseNode._get_child_with[TypeType](
        obj,
        children,
        "ret_type",
        "ExpLambda.ret_type must be a TypeType",
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
        return "ExpLambda.partial must be a boolean"
      else
        false
      end
    let body =
      match ParseNode._get_child_with[Expression](
        obj,
        children,
        "body",
        "ExpLambda.body must be an Expression")
      | let node: NodeWith[Expression] =>
        node
      | let err: String =>
        return err
      else
        return "ExpLambda.body must be an Expression"
      end
    let ref_cap =
      match ParseNode._get_child_with[Keyword](
        obj,
        children,
        "ref_cap",
        "ExpLambda.ref_cap must be a Keyword",
        false)
      | let node: NodeWith[Keyword] =>
        node
      | let err: String =>
        return err
      end
    ExpLambda(
      bare,
      this_cap,
      identifier,
      type_params,
      params,
      captures,
      ret_type,
      partial,
      body,
      ref_cap)
