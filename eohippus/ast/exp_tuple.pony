use json = "../json"

class val ExpTuple is NodeData
  """A tuple expression."""

  let sequences: NodeSeqWith[Expression]

  new val create(sequences': NodeSeqWith[Expression]) =>
    sequences = sequences'

  fun name(): String => "ExpTuple"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    ExpTuple(_map[Expression](sequences, updates))

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    if sequences.size() > 0 then
      props.push(("sequences", node.child_refs(sequences)))
    end

primitive ParseExpTuple
  fun apply(obj: json.Object, children: NodeSeq): (ExpTuple | String) =>
    let sequences =
      match ParseNode._get_seq_with[Expression](
        obj,
        children,
        "sequences",
        "ExpTuple.sequences must be a sequence of Expressions")
      | let seq: NodeSeqWith[Expression] =>
        seq
      | let err: String =>
        return err
      end
    ExpTuple(sequences)
