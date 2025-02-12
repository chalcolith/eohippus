use json = "../json"

class val TypedefClass is NodeData
  """
    A class-like type definition (a `trait`, `interface`, `class`, `struct` or
    `actor`).
  """

  let kind: NodeWith[Keyword]
  let raw: Bool
  let cap: (NodeWith[Keyword] | None)
  let identifier: NodeWith[Identifier]
  let type_params: (NodeWith[TypeParams] | None)
  let constraint: (NodeWith[TypeType] | None)
  let members: (NodeWith[TypedefMembers] | None)

  new val create(
    kind': NodeWith[Keyword],
    raw': Bool,
    cap': (NodeWith[Keyword] | None),
    identifier': NodeWith[Identifier],
    type_params': (NodeWith[TypeParams] | None),
    constraint': (NodeWith[TypeType] | None),
    members': (NodeWith[TypedefMembers] | None))
  =>
    kind = kind'
    raw = raw'
    cap = cap'
    identifier = identifier'
    type_params = type_params'
    constraint = constraint'
    members = members'

  fun name(): String => "TypedefClass"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    TypedefClass(
      _map_with[Keyword](kind, updates),
      raw,
      _map_or_none[Keyword](cap, updates),
      _map_with[Identifier](identifier, updates),
      _map_or_none[TypeParams](type_params, updates),
      _map_or_none[TypeType](constraint, updates),
      _map_or_none[TypedefMembers](members, updates))

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    props.push(("kind", node.child_ref(kind)))
    if raw then
      props.push(("raw", raw))
    end
    match cap
    | let cap': NodeWith[Keyword] =>
      props.push(("cap", node.child_ref(cap')))
    end
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

primitive ParseTypedefClass
  fun apply(obj: json.Object val, children: NodeSeq): (TypedefClass | String) =>
    let kind =
      match ParseNode._get_child_with[Keyword](
        obj,
        children,
        "kind",
        "TypedefClass.kind must be a Keyword")
      | let node: NodeWith[Keyword] =>
        node
      | let err: String =>
        return err
      else
        return "TypedefClass.kind must be a Keyword"
      end
    let raw =
      match try obj("raw")? end
      | let bool: Bool =>
        bool
      | let item: json.Item =>
        return "TypedefClass.raw must be a boolean"
      else
        false
      end
    let cap =
      match ParseNode._get_child_with[Keyword](
        obj,
        children,
        "cap",
        "TypedefClass.cap must be a Keyword",
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
        "TypedefClass.identifier must be an Identifier")
      | let node: NodeWith[Identifier] =>
        node
      | let err: String =>
        return err
      else
        return "TypedefClass.identifier must be an Identifier"
      end
    let type_params =
      match ParseNode._get_child_with[TypeParams](
        obj,
        children,
        "type_params",
        "TypedefClass.type_params must be a TypeParams",
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
        "TypedefClass.constraint must be a TypeType",
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
        "TypedefClass.members must be a TypedefMembers",
        false)
      | let node: NodeWith[TypedefMembers] =>
        node
      | let err: String =>
        return err
      end
    TypedefClass(kind, raw, cap, identifier, type_params, constraint, members)
