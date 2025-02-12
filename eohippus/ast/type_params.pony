use json = "../json"

class val TypeParams is NodeData
  """Type parameters."""

  let params: NodeSeqWith[TypeParam]

  new val create(params': NodeSeqWith[TypeParam]) =>
    params = params'

  fun name(): String => "TypeParams"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    TypeParams(_map[TypeParam](params, updates))

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    if params.size() > 0 then
      props.push(("params", node.child_refs(params)))
    end

primitive ParseTypeParams
  fun apply(obj: json.Object val, children: NodeSeq): (TypeParams | String) =>
    let params =
      match ParseNode._get_seq_with[TypeParam](
        obj,
        children,
        "params",
        "TypeParams.params must be a sequence of TypeParam",
        false)
      | let seq: NodeSeqWith[TypeParam] =>
        seq
      | let err: String =>
        return err
      end
    TypeParams(params)

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

  fun val clone(updates: ChildUpdateMap): NodeData =>
    TypeParam(
      _map_or_none[Identifier](identifier, updates),
      _map_or_none[TypeType](constraint, updates),
      _map_or_none[TypeType](initializer, updates))

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
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

primitive ParseTypeParam
  fun apply(obj: json.Object val, children: NodeSeq): (TypeParam | String) =>
    let identifier =
      match ParseNode._get_child_with[Identifier](
        obj,
        children,
        "identifier",
        "TypeParam.identifier must be an identifier",
        false)
      | let node: NodeWith[Identifier] =>
        node
      | let err: String =>
        return err
      end
    let constraint =
      match ParseNode._get_child_with[TypeType](
        obj,
        children,
        "constraint",
        "TypeParam.constraint must be a TypeType",
        false)
      | let node: NodeWith[TypeType] =>
        node
      | let err: String =>
        return err
      end
    let initializer =
      match ParseNode._get_child_with[TypeType](
        obj,
        children,
        "initializer",
        "TypeParam.initializer must be a TypeType",
        false)
      | let node: NodeWith[TypeType] =>
        node
      | let err: String =>
        return err
      end
    TypeParam(identifier, constraint, initializer)
