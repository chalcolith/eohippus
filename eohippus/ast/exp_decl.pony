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

  fun val clone(updates: ChildUpdateMap): ExpDecl =>
    ExpDecl(
      _map_with[Keyword](kind, updates),
      _map_with[Identifier](identifier, updates),
      _map_or_none[TypeType](decl_type, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("kind", node.child_ref(kind)))
    props.push(("identifier", node.child_ref(identifier)))
    match decl_type
    | let decl_type': NodeWith[TypeType] =>
      props.push(("decl_type", node.child_ref(decl_type')))
    end
