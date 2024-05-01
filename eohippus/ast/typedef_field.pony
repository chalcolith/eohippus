use json = "../json"

class val TypedefField is NodeData
  """
    A field definition.
    - `kind`: `let`, `var`, or `embed`.
  """

  let kind: NodeWith[Keyword]
  let identifier: NodeWith[Identifier]
  let type_type: (NodeWith[TypeType] | None)
  let initializer: (NodeWith[Expression] | None)

  new val create(
    kind': NodeWith[Keyword],
    identifier': NodeWith[Identifier],
    type_type': (NodeWith[TypeType] | None),
    initializer': (NodeWith[Expression] | None))
  =>
    kind = kind'
    identifier = identifier'
    type_type = type_type'
    initializer = initializer'

  fun name(): String => "TypedefField"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    TypedefField(
      _map_with[Keyword](kind, updates),
      _map_with[Identifier](identifier, updates),
      _map_or_none[TypeType](type_type, updates),
      _map_or_none[Expression](initializer, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("kind", node.child_ref(kind)))
    props.push(("identifier", node.child_ref(identifier)))
    match type_type
    | let type_type': NodeWith[TypeType] =>
      props.push(("type", node.child_ref(type_type')))
    end
    match initializer
    | let initializer': NodeWith[Expression] =>
      props.push(("initializer", node.child_ref(initializer')))
    end

primitive ParseTypedefField
  fun apply(obj: json.Object, children: NodeSeq): (TypedefField | String) =>
    let kind =
      match ParseNode._get_child_with[Keyword](
        obj,
        children,
        "kind",
        "TypedefField.kind must be a Keyword")
      | let node: NodeWith[Keyword] =>
        node
      | let err: String =>
        return err
      else
        return "TypedefField.kind must be a Keyword"
      end
    let identifier =
      match ParseNode._get_child_with[Identifier](
        obj,
        children,
        "identifier",
        "TypedefField.identifier must be an Identifier")
      | let node: NodeWith[Identifier] =>
        node
      | let err: String =>
        return err
      else
        return "TypedefField.identifier must be an Identifier"
      end
    let type_type =
      match ParseNode._get_child_with[TypeType](
        obj,
        children,
        "type",
        "TypedefField.type must be a TypeType",
        false)
      | let node: NodeWith[TypeType] =>
        node
      | let err: String =>
        return err
      end
    let initializer =
      match ParseNode._get_child_with[Expression](
        obj,
        children,
        "value",
        "TypedefField.value must be an Expression",
        false)
      | let node: NodeWith[Expression] =>
        node
      | let err: String =>
        return err
      end
    TypedefField(kind, identifier, type_type, initializer)
