use json = "../json"

class val Annotation is NodeData
  """Contains a list of identifiers."""

  let identifiers: NodeSeqWith[Identifier]

  new val create(identifiers': NodeSeqWith[Identifier]) =>
    identifiers = identifiers'

  fun val clone(updates: ChildUpdateMap): NodeData =>
    Annotation(_map[Identifier](identifiers, updates))

  fun name(): String => "Annotation"

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("identifiers", node.child_refs(identifiers)))
