use json = "../json"

class val TypedefPrimitive is NodeData
  """A primitive type declaration."""

  let identifier: NodeWith[Identifier]
  let type_params: (NodeWith[TypeParams] | None)
  let constraint: (NodeWith[TypeType] | None)
  let members: (NodeWith[TypedefMembers] | None)

  new val create(
    identifier': NodeWith[Identifier],
    type_params': (NodeWith[TypeParams] | None),
    constraint': (NodeWith[TypeType] | None),
    members': (NodeWith[TypedefMembers] | None))
  =>
    identifier = identifier'
    type_params = type_params'
    constraint = constraint'
    members = members'

  fun name(): String => "TypedefPrimitive"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    TypedefPrimitive(
      _map_with[Identifier](identifier, updates),
      _map_or_none[TypeParams](type_params, updates),
      _map_or_none[TypeType](constraint, updates),
      _map_or_none[TypedefMembers](members, updates))

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    props.push(("identifier", node.child_ref(identifier)))
    match type_params
    | let type_params': NodeWith[TypeParams] =>
      props.push(("type_params", node.child_ref(type_params')))
    end
    match constraint
    | let constraint': NodeWith[TypeType] =>
      props.push(("constraint", node.child_ref(constraint')))
    end
    match members
    | let members': NodeWith[TypedefMembers] =>
      props.push(("members", node.child_ref(members')))
    end

primitive ParseTypedefPrimitive
  fun apply(obj: json.Object val, children: NodeSeq): (TypedefPrimitive | String) =>
    let identifier =
      match ParseNode._get_child_with[Identifier](
        obj,
        children,
        "identifier",
        "TypedefPrimitive.identifier must be an Identifier")
      | let node: NodeWith[Identifier] =>
        node
      | let err: String =>
        return err
      else
        return "TypedefPrimitive.identifier must be an Identifier"
      end
    let type_params =
      match ParseNode._get_child_with[TypeParams](
        obj,
        children,
        "type_params",
        "TypedefPrimitive.type_params must be a TypeParams",
        false)
      | let node: NodeWith[TypeParams] =>
        node
      | let err: String =>
        return err
      end
    let constraint =
      match ParseNode._get_child_with[TypeType](
        obj,
        children,
        "constraint",
        "TypedefPrimitive.constraint must be a TypeType",
        false)
      | let node: NodeWith[TypeType] =>
        node
      | let err: String =>
        return err
      end
    let members =
      match ParseNode._get_child_with[TypedefMembers](
        obj,
        children,
        "members",
        "TypedefPrimitive.members must be a TypedefMembers",
        false)
      | let node: NodeWith[TypedefMembers] =>
        node
      | let err: String =>
        return err
      end
    TypedefPrimitive(identifier, type_params, constraint, members)
