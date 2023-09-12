use json = "../json"

class val ExpDecl is NodeData
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

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("kind", kind.get_json()))
    props.push(("identifier", identifier.get_json()))
    match decl_type
    | let decl_type': NodeWith[TypeType] =>
      props.push(("decl_type", decl_type'.get_json()))
    end
