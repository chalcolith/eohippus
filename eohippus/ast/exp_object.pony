use json = "../json"

class val ExpObject is NodeData
  """An object literal."""

  let cap: (NodeWith[Keyword] | None)
  let constraint: (NodeWith[TypeType] | None)
  let members: NodeWith[TypedefMembers]

  new val create(
    cap': (NodeWith[Keyword] | None),
    constraint': (NodeWith[TypeType] | None),
    members': NodeWith[TypedefMembers])
  =>
    cap = cap'
    constraint = constraint'
    members = members'

  fun name(): String => "ExpObject"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    ExpObject(
      _map_or_none[Keyword](cap, updates),
      _map_or_none[TypeType](constraint, updates),
      _map_with[TypedefMembers](members, updates))

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    match cap
    | let cap': NodeWith[Keyword] =>
      props.push(("cap", node.child_ref(cap')))
    end
    match constraint
    | let constraint': NodeWith[TypeType] =>
      props.push(("constraint", node.child_ref(constraint')))
    end
    props.push(("members", node.child_ref(members)))

primitive ParseExpObject
  fun apply(obj: json.Object, children: NodeSeq): (ExpObject | String) =>
    let cap =
      match ParseNode._get_child_with[Keyword](
        obj,
        children,
        "cap",
        "ExpObject.cap must be a Keyword",
        false)
      | let node: NodeWith[Keyword] =>
        node
      | let err: String =>
        return err
      end
    let constraint =
      match ParseNode._get_child_with[TypeType](
        obj,
        children,
        "constraint",
        "ExpObject.constraint must be a TypeType",
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
        "ExpObject.members must be a TypedefMembers")
      | let node: NodeWith[TypedefMembers] =>
        node
      | let err: String =>
        return err
      else
        return "ExpObject.members must be a TypedefMembers"
      end
    ExpObject(cap, constraint, members)
