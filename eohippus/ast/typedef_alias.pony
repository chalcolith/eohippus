use json = "../json"

class val TypedefAlias is NodeData
  """A type alias."""

  let identifier: NodeWith[Identifier]
  let type_params: (NodeWith[TypeParams] | None)
  let type_type: NodeWith[TypeType]

  new val create(
    identifier': NodeWith[Identifier],
    type_params': (NodeWith[TypeParams] | None),
    type_type': NodeWith[TypeType])
  =>
    identifier = identifier'
    type_params = type_params'
    type_type = type_type'

  fun name(): String => "TypedefAlias"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    TypedefAlias(
      NodeChild.child_with[Identifier](identifier, old_children, new_children)?,
      NodeChild.with_or_none[TypeParams](type_params, old_children, new_children)?,
      NodeChild.child_with[TypeType](type_type, old_children, new_children)?)

  fun add_json_props(
    props: Array[(String, json.Item)],
    lines_and_columns: (LineColumnMap | None) = None)
  =>
    props.push(("identifier", identifier.get_json(lines_and_columns)))
    match type_params
    | let type_params': NodeWith[TypeParams] =>
      props.push(("type_params", type_params'.get_json(lines_and_columns)))
    end
    props.push(("type", type_type.get_json(lines_and_columns)))
