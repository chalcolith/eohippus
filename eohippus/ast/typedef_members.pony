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

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    let f = NodeChild.seq_with[TypedefField](fields, old_children, new_children)?
    let m = NodeChild.seq_with[TypedefMethod](methods, old_children, new_children)?

    TypedefMembers(
      f,
      m)

  fun add_json_props(
    props: Array[(String, json.Item)],
    lines_and_columns: (LineColumnMap | None) = None)
  =>
    if fields.size() > 0 then
      props.push(("fields", Nodes.get_json(fields, lines_and_columns)))
    end
    if methods.size() > 0 then
      props.push(("methods", Nodes.get_json(methods, lines_and_columns)))
    end
