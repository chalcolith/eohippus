use json = "../json"

class val ExpArray is NodeData
  """
    An array literal.
    - `array_type`: the explicit type of the array elements, if any.
    - `body`: will usually be an `ExpSequence`.
  """
  let array_type: (NodeWith[TypeType] | None)
  let body: (NodeWith[Expression] | None)

  new val create(
    array_type': (NodeWith[TypeType] | None),
    body': (NodeWith[Expression] | None))
  =>
    array_type = array_type'
    body = body'

  fun name(): String => "ExpArray"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    ExpArray(
      _map_or_none[TypeType](array_type, updates),
      _map_or_none[Expression](body, updates))

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    match array_type
    | let array_type': NodeWith[TypeType] =>
      props.push(("type", node.child_ref(array_type')))
    end
    match body
    | let body': NodeWith[Expression] =>
      props.push(("body", node.child_ref(body')))
    end

primitive ParseExpArray
  fun apply(obj: json.Object val, children: NodeSeq): (ExpArray | String) =>
    let array_type =
      match ParseNode._get_child_with[TypeType](
        obj,
        children,
        "type",
        "ExpArray.type must be a TypeType",
        false)
      | let node: NodeWith[TypeType] =>
        node
      | let err: String =>
        return err
      end
    let body =
      match ParseNode._get_child_with[Expression](
        obj,
        children,
        "body",
        "ExpArray.body must be an Expression")
      | let node: NodeWith[Expression] =>
        node
      | let err: String =>
        return err
      end
    ExpArray(array_type, body)
