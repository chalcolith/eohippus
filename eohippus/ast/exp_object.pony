use json = "../json"

class val ExpObject is NodeData
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

  fun add_json_props(props: Array[(String, json.Item)]) =>
    match cap
    | let cap': NodeWith[Keyword] =>
      props.push(("cap", cap'.get_json()))
    end
    match constraint
    | let constraint': NodeWith[TypeType] =>
      props.push(("constraint", constraint'.get_json()))
    end
    props.push(("members", members.get_json()))
