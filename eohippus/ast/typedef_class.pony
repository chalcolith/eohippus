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

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    TypedefClass(
      NodeChild.child_with[Keyword](kind, old_children, new_children)?,
      raw,
      NodeChild.with_or_none[Keyword](cap, old_children, new_children)?,
      NodeChild.child_with[Identifier](identifier, old_children, new_children)?,
      NodeChild.with_or_none[TypeParams](type_params, old_children, new_children)?,
      NodeChild.with_or_none[TypeType](constraint, old_children, new_children)?,
      NodeChild.with_or_none[TypedefMembers](members, old_children, new_children)?)

  fun add_json_props(
    props: Array[(String, json.Item)],
    lines_and_columns: (LineColumnMap | None) = None)
  =>
    props.push(("kind", kind.get_json(lines_and_columns)))
    if raw then
      props.push(("raw", raw))
    end
    match cap
    | let cap': NodeWith[Keyword] =>
      props.push(("cap", cap'.get_json(lines_and_columns)))
    end
    props.push(("identifier", identifier.get_json(lines_and_columns)))
    match type_params
    | let type_params': NodeWith[TypeParams] =>
      props.push(("type_params", type_params'.get_json(lines_and_columns)))
    end
    match constraint
    | let constraint': NodeWith[TypeType] =>
      props.push(("constraint", constraint'.get_json(lines_and_columns)))
    end
    match members
    | let members': NodeWith[TypedefMembers] =>
      props.push(("members", members'.get_json(lines_and_columns)))
    end
