use json = "../json"

class val ExpDecl is NodeData
  """
    An alias declaration.  Usually the LHS of an assignment expression.
    - `kind`: `let` or `var`.
    - `identifier`: the name of the binding.
    - `decl_type`: the type, if any.
  """

  let kind: NodeWith[Keyword]
  let identifier: NodeWith[Identifier]
  let decl_type: (NodeWith[TypeType] | None)

  new val create(
    kind': NodeWith[Keyword],
    identifier': NodeWith[Identifier],
    decl_type': (NodeWith[TypeType] | None))
  =>
    kind = kind'
    identifier = identifier'
    decl_type = decl_type'

  fun name(): String => "ExpDecl"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    ExpDecl(
      _map_with[Keyword](kind, updates),
      _map_with[Identifier](identifier, updates),
      _map_or_none[TypeType](decl_type, updates))

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    props.push(("kind", node.child_ref(kind)))
    props.push(("identifier", node.child_ref(identifier)))
    match decl_type
    | let decl_type': NodeWith[TypeType] =>
      props.push(("decl_type", node.child_ref(decl_type')))
    end

primitive ParseExpDecl
  fun apply(obj: json.Object, children: NodeSeq): (ExpDecl | String) =>
    let kind =
      match ParseNode._get_child_with[Keyword](
        obj, children, "kind", "ExpDecl.kind must be a Keyword")
      | let node: NodeWith[Keyword] =>
        node
      | let err: String =>
        return err
      else
        return "ExpDecl.kind must be a Keyword"
      end
    let identifier =
      match ParseNode._get_child_with[Identifier](
        obj,
        children,
        "identifier",
        "ExpDecl.identifier must be an Identifier")
      | let node: NodeWith[Identifier] =>
        node
      | let err: String =>
        return err
      else
        return "ExpDecl.identifier must be an Identifier"
      end
    let decl_type =
      match ParseNode._get_child_with[TypeType](
        obj,
        children,
        "decl_type",
        "ExpDecl.decl_type must be a TypeType",
        false)
      | let node: NodeWith[TypeType] =>
        node
      | let err: String =>
        return err
      end
    ExpDecl(kind, identifier, decl_type)
