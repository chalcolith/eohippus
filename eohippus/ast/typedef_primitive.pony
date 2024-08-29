use json = "../json"

class val TypedefPrimitive is NodeData
  """A primitive type declaration."""

  let identifier: NodeWith[Identifier]

  new val create(identifier': NodeWith[Identifier]) =>
    identifier = identifier'

  fun name(): String => "TypedefPrimitive"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    TypedefPrimitive(_map_with[Identifier](identifier, updates))

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    props.push(("identifier", node.child_ref(identifier)))

primitive ParseTypedefPrimitive
  fun apply(obj: json.Object, children: NodeSeq): (TypedefPrimitive | String) =>
    let identifier =
      match ParseNode._get_child_with[Identifier](
        obj,
        children,
        "identifier",
        "TypedefPrimitive.identifier must be an Identifier")
      | let node: NodeWith[Identifier] =>
        node
      | let err: String =>
        return err
      else
        return "TypedefPrimitive.identifier must be an Identifier"
      end
    TypedefPrimitive(identifier)
