use json = "../json"

class val TypeTuple is NodeData
  """A tuple type."""
  let types: NodeSeqWith[TypeType]

  new val create(types': NodeSeqWith[TypeType]) =>
    types = types'

  fun name(): String => "TypeTuple"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    TypeTuple(NodeChild.seq_with[TypeType](types, old_children, new_children)?)

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("types", node.child_refs(types)))
