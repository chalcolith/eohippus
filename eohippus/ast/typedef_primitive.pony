use json = "../json"

type Typedef is (TypedefPrimitive | TypedefAlias | TypedefClass)

class val TypedefPrimitive is NodeData
  let identifier: NodeWith[Identifier]

  new val create(identifier': NodeWith[Identifier]) =>
    identifier = identifier'

  fun name(): String => "TypedefPrimitive"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("identifier", identifier.get_json()))
