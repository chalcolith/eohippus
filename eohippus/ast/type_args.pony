use json = "../json"

class val TypeArgs is NodeData
  """
    Type arguments in expressions.
  """

  let types: NodeSeqWith[TypeType]

  new val create(types': NodeSeqWith[TypeType]) =>
    types = types'

  fun name(): String => "TypeArgs"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    TypeArgs(_map[TypeType](types, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("types", node.child_refs(types)))
