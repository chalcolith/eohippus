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

primitive ParseTypeArgs
  fun apply(obj: json.Object, children: NodeSeq): (TypeArgs | String) =>
    let types =
      match ParseNode._get_seq_with[TypeType](
        obj,
        children,
        "types",
        "TypeArgs.types must be a sequence of TypeType")
      | let seq: NodeSeqWith[TypeType] =>
        seq
      | let err: String =>
        return err
      end
    TypeArgs(types)
