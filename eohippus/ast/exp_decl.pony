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

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    ExpDecl(
      NodeChild.child_with[Keyword](kind, old_children, new_children)?,
      NodeChild.child_with[Identifier](identifier, old_children, new_children)?,
      NodeChild.with_or_none[TypeType](decl_type, old_children, new_children)?)

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("kind", kind.get_json()))
    props.push(("identifier", identifier.get_json()))
    match decl_type
    | let decl_type': NodeWith[TypeType] =>
      props.push(("decl_type", decl_type'.get_json()))
    end
