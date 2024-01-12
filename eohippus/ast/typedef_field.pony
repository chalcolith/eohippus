use json = "../json"

class val TypedefField is NodeData
  let kind: NodeWith[Keyword]
  let identifier: NodeWith[Identifier]
  let type_type: (NodeWith[TypeType] | None)
  let value: (NodeWith[Expression] | None)

  new val create(
    kind': NodeWith[Keyword],
    identifier': NodeWith[Identifier],
    type_type': (NodeWith[TypeType] | None),
    value': (NodeWith[Expression] | None))
  =>
    kind = kind'
    identifier = identifier'
    type_type = type_type'
    value = value'

  fun name(): String => "TypedefField"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    TypedefField(
      NodeChild.child_with[Keyword](kind, old_children, new_children)?,
      NodeChild.child_with[Identifier](identifier, old_children, new_children)?,
      NodeChild.with_or_none[TypeType](type_type, old_children, new_children)?,
      NodeChild.with_or_none[Expression](value, old_children, new_children)?)

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("kind", kind.get_json()))
    props.push(("identifier", identifier.get_json()))
    match type_type
    | let type_type': NodeWith[TypeType] =>
      props.push(("type", type_type'.get_json()))
    end
    match value
    | let value': NodeWith[Expression] =>
      props.push(("value", value'.get_json()))
    end
