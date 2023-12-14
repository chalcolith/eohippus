use json = "../json"

class val TypedefClass is NodeData
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

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("kind", kind.get_json()))
    if raw then
      props.push(("raw", raw))
    end
    match cap
    | let cap': NodeWith[Keyword] =>
      props.push(("cap", cap'.get_json()))
    end
    props.push(("identifier", identifier.get_json()))
    match type_params
    | let type_params': NodeWith[TypeParams] =>
      props.push(("type_params", type_params'.get_json()))
    end
    match constraint
    | let constraint': NodeWith[TypeType] =>
      props.push(("constraint", constraint'.get_json()))
    end
    match members
    | let members': NodeWith[TypedefMembers] =>
      props.push(("members", members'.get_json()))
    end
