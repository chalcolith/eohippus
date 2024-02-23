use "itertools"

use json = "../json"

primitive Nodes
  fun get_json(
    seq: NodeSeq,
    lines_and_columns: (LineColumnMap | None) = None)
    : json.Sequence box
  =>
    """Get a JSON sequence for a sequence of nodes."""
    json.Sequence.from_iter(
      Iter[Node](seq.values())
        .map[json.Item]({(n) => n.get_json(lines_and_columns)}))
