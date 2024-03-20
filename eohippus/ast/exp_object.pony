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

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    ExpObject(
      NodeChild.with_or_none[Keyword](cap, old_children, new_children)?,
      NodeChild.with_or_none[TypeType](constraint, old_children, new_children)?,
      NodeChild.child_with[TypedefMembers](members, old_children, new_children)?)

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    match cap
    | let cap': NodeWith[Keyword] =>
      props.push(("cap", node.child_ref(cap')))
    end
    match constraint
    | let constraint': NodeWith[TypeType] =>
      props.push(("constraint", node.child_ref(constraint')))
    end
    props.push(("members", node.child_ref(members)))
