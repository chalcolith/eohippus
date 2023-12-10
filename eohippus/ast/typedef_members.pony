use json = "../json"

class val TypedefMembers is NodeData
  let fields: NodeSeqWith[TypedefField]
  let methods: NodeSeqWith[TypedefMethod]

  new val create(
    fields': NodeSeqWith[TypedefField],
    methods': NodeSeqWith[TypedefMethod])
  =>
    fields = fields'
    methods = methods'

  fun name(): String => "TypedefMembers"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    if fields.size() > 0 then
      props.push(("fields", Nodes.get_json(fields)))
    end
    if methods.size() > 0 then
      props.push(("methods", Nodes.get_json(methods)))
    end
