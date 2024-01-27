use "itertools"

use json = "../json"

primitive Nodes
  fun get_json(seq: NodeSeq): json.Sequence box =>
    """Get a JSON sequence for a sequence of nodes."""
    json.Sequence.from_iter(
      Iter[Node](seq.values()).map[json.Item]({(n) => n.get_json()}))
