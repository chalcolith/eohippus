use json = "../json"
use parser = "../parser"

type TypeDef is TypeDefPrimitive

class val TypeDefPrimitive is NodeData
  let identifier: NodeWith[Identifier]

  new val create(identifier': NodeWith[Identifier]) =>
    identifier = identifier'

  fun name(): String => "TypeDefPrimitive"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("identifier", identifier.get_json()))
