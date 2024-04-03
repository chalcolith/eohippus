use json = "../json"

class val TypeTuple is NodeData
  """A tuple type."""
  let types: NodeSeqWith[TypeType]

  new val create(types': NodeSeqWith[TypeType]) =>
    types = types'

  fun name(): String => "TypeTuple"

  fun val clone(updates: ChildUpdateMap): TypeTuple =>
    TypeTuple(_map[TypeType](types, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("types", node.child_refs(types)))
