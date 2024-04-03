use json = "../json"

class val TypedefField is NodeData
  """
    A field definition.
    - `kind`: `let`, `var`, or `embed`.
  """

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

  fun val clone(updates: ChildUpdateMap): TypedefField =>
    TypedefField(
      _map_with[Keyword](kind, updates),
      _map_with[Identifier](identifier, updates),
      _map_or_none[TypeType](type_type, updates),
      _map_or_none[Expression](value, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("kind", node.child_ref(kind)))
    props.push(("identifier", node.child_ref(identifier)))
    match type_type
    | let type_type': NodeWith[TypeType] =>
      props.push(("type", node.child_ref(type_type')))
    end
    match value
    | let value': NodeWith[Expression] =>
      props.push(("value", node.child_ref(value')))
    end
