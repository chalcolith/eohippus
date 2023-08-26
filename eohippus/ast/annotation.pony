use json = "../json"

class val Annotation is NodeData
  let identifiers: NodeSeqWith[Identifier]

  new val create(identifiers': NodeSeqWith[Identifier]) =>
    identifiers = identifiers'

  fun name(): String => "Annotation"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("identifiers", Nodes.get_json(identifiers)))
