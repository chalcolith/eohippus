use json = "../json"

class val Annotation is NodeData
  """Contains a list of identifiers."""

  let identifiers: NodeSeqWith[Identifier]

  new val create(identifiers': NodeSeqWith[Identifier]) =>
    identifiers = identifiers'

  fun val clone(updates: ChildUpdateMap): NodeData =>
    Annotation(_map[Identifier](identifiers, updates))

  fun name(): String => "Annotation"

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    props.push(("identifiers", node.child_refs(identifiers)))

primitive ParseAnnotation
  fun apply(obj: json.Object val, children: NodeSeq): (Annotation | String) =>
    let identifiers =
      match ParseNode._get_seq_with[Identifier](
        obj,
        children,
        "identifiers",
        "Annotation.identifiers must refer to Identifiers")
      | let seq: NodeSeqWith[Identifier] =>
        seq
      | let err: String =>
        return err
      end
    Annotation(identifiers)
