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

  fun val clone(updates: ChildUpdateMap): NodeData =>
    TypedefAlias(
      _map_with[Identifier](identifier, updates),
      _map_or_none[TypeParams](type_params, updates),
      _map_with[TypeType](type_type, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("identifier", node.child_ref(identifier)))
    match type_params
    | let type_params': NodeWith[TypeParams] =>
      props.push(("type_params", node.child_ref(type_params')))
    end
    props.push(("type", node.child_ref(type_type)))

primitive ParseTypedefAlias
  fun apply(obj: json.Object, children: NodeSeq): (TypedefAlias | String) =>
    let identifier =
      match ParseNode._get_child_with[Identifier](
        obj,
        children,
        "identifier",
        "TypedefAlias.identifier must be an Identifier")
      | let node: NodeWith[Identifier] =>
        node
      | let err: String =>
        return err
      else
        return "TypedefAlias.identifier must be an Identifier"
      end
    let type_params =
      match ParseNode._get_child_with[TypeParams](
        obj,
        children,
        "type_params",
        "TypedefAlias.type_params must be a TypeParams",
        false)
      | let node: NodeWith[TypeParams] =>
        node
      | let err: String =>
        return err
      end
    let type_type =
      match ParseNode._get_child_with[TypeType](
        obj,
        children,
        "type",
        "TypedefAlias.type must be a TypeType")
      | let node: NodeWith[TypeType] =>
        node
      | let err: String =>
        return err
      else
        return "TypedefAlias.type must be a TypeType"
      end
    TypedefAlias(identifier, type_params, type_type)
