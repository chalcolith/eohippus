use json = "../json"

class val ExpTuple is NodeData
  """A tuple expression."""

  let sequences: NodeSeqWith[Expression]

  new val create(sequences': NodeSeqWith[Expression]) =>
    sequences = sequences'

  fun name(): String => "ExpTuple"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    ExpTuple(
      NodeChild.seq_with[Expression](sequences, old_children, new_children)?)

  fun add_json_props(
    props: Array[(String, json.Item)],
    lines_and_columns: (LineColumnMap | None) = None)
  =>
    if sequences.size() > 0 then
      props.push(("sequences", Nodes.get_json(sequences, lines_and_columns)))
    end
