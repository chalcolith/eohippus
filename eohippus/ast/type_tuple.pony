use json = "../json"

class val TypeTuple is NodeData
  """A tuple type."""
  let types: NodeSeqWith[TypeType]

  new val create(types': NodeSeqWith[TypeType]) =>
    types = types'

  fun name(): String => "TypeTuple"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    TypeTuple(_map[TypeType](types, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    if types.size() > 0 then
      props.push(("types", node.child_refs(types)))
    end

primitive ParseTypeTuple
  fun apply(obj: json.Object, children: NodeSeq): (TypeTuple | String) =>
    let types =
      match ParseNode._get_seq_with[TypeType](
        obj,
        children,
        "types",
        "TypeTuple.types must be a sequence of TypeType",
        false)
      | let seq: NodeSeqWith[TypeType] =>
        seq
      | let err: String =>
        return err
      end
    TypeTuple(types)
