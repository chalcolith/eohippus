use json = "../json"

class val ExpFfi is NodeData
  """
    An FFI call.
  """

  let identifier: (NodeWith[Identifier] | NodeWith[LiteralString])
  let type_args: (NodeWith[TypeArgs] | None)
  let call_args: NodeWith[CallArgs]
  let partial: Bool

  new val create(
    identifier': (NodeWith[Identifier] | NodeWith[LiteralString]),
    type_args': (NodeWith[TypeArgs] | None),
    call_args': NodeWith[CallArgs],
    partial': Bool)
  =>
    identifier = identifier'
    type_args = type_args'
    call_args = call_args'
    partial = partial'

  fun name(): String => "ExpFfi"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    ExpFfi(
      try
        updates(identifier)? as (NodeWith[Identifier] | NodeWith[LiteralString])
      else
        identifier
      end,
      _map_or_none[TypeArgs](type_args, updates),
      _map_with[CallArgs](call_args, updates),
      partial)

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("identifier", node.child_ref(identifier)))
    match type_args
    | let type_args': NodeWith[TypeArgs] =>
      props.push(("type_args", node.child_ref(type_args')))
    end
    props.push(("call_args", node.child_ref(call_args)))
    if partial then
      props.push(("partial", partial))
    end

primitive ParseExpFfi
  fun help_id(): String => "ExpFfi.identifier must be an Identifier or Literal"

  fun apply(obj: json.Object, children: NodeSeq): (ExpFfi | String) =>
    let identifier =
      match ParseNode._get_child(obj, children, "identifier", help_id())
      | let node: Node =>
        match node
        | let identifier': NodeWith[Identifier] =>
          identifier'
        | let literal': NodeWith[LiteralString] =>
          literal'
        else
          return help_id()
        end
      | let err: String =>
        return err
      else
        return help_id()
      end
    let type_args =
      match ParseNode._get_child_with[TypeArgs](
        obj,
        children,
        "type_args",
        "ExpFfi.type_args must be a TypeArgs",
        false)
      | let node: NodeWith[TypeArgs] =>
        node
      | let err: String =>
        return err
      end
    let call_args =
      match ParseNode._get_child_with[CallArgs](
        obj,
        children,
        "call_args",
        "ExpFfi.call_args must be a CallArgs")
      | let node: NodeWith[CallArgs] =>
        node
      | let err: String =>
        return err
      else
        return "ExpFfi.call_args must be a CallArgs"
      end
    let partial =
      match try obj("partial")? end
      | let bool: Bool =>
        bool
      | let item: json.Item =>
        return "ExpFfi.partial must be a boolean"
      else
        false
      end
    ExpFfi(identifier, type_args, call_args, partial)
