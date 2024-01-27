use json = "../json"

class val Annotation is NodeData
  """Contains a list of identifiers."""

  let identifiers: NodeSeqWith[Identifier]

  new val create(identifiers': NodeSeqWith[Identifier]) =>
    identifiers = identifiers'

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    Annotation(
      NodeChild.seq_with[Identifier](identifiers, old_children, new_children)?)

  fun name(): String => "Annotation"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("identifiers", Nodes.get_json(identifiers)))
