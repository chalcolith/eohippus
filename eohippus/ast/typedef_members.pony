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

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    if fields.size() > 0 then
      props.push(("fields", node.child_refs(fields)))
    end
    if methods.size() > 0 then
      props.push(("methods", node.child_refs(methods)))
    end

primitive ParseTypedefMembers
  fun apply(obj: json.Object val, children: NodeSeq)
    : (TypedefMembers | String)
  =>
    let fields =
      match ParseNode._get_seq_with[TypedefField](
        obj,
        children,
        "fields",
        "TypedefMembers.fields must be a sequence of TypedefField",
        false)
      | let seq: NodeSeqWith[TypedefField] =>
        seq
      | let err: String =>
        return err
      end
    let methods =
      match ParseNode._get_seq_with[TypedefMethod](
        obj,
        children,
        "methods",
        "TypedefMembers.methods must be a sequence of TypedefMethod",
        false)
      | let seq: NodeSeqWith[TypedefMethod] =>
        seq
      | let err: String =>
        return err
      end
    TypedefMembers(fields, methods)
