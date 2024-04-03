use json = "../json"

class val TypedefMembers is NodeData
  """
    The members of a class-like type.
  """

  let fields: NodeSeqWith[TypedefField]
  let methods: NodeSeqWith[TypedefMethod]

  new val create(
    fields': NodeSeqWith[TypedefField],
    methods': NodeSeqWith[TypedefMethod])
  =>
    fields = fields'
    methods = methods'

  fun name(): String => "TypedefMembers"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    TypedefMembers(
      _map[TypedefField](fields, updates),
      _map[TypedefMethod](methods, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    if fields.size() > 0 then
      props.push(("fields", node.child_refs(fields)))
    end
    if methods.size() > 0 then
      props.push(("methods", node.child_refs(methods)))
    end
