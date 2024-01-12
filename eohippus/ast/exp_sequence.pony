use "itertools"

use json = "../json"

class val ExpSequence is NodeData
  let expressions: NodeSeqWith[Expression]

  new val create(expressions': NodeSeqWith[Expression]) =>
    expressions = expressions'

  fun name(): String => "ExpSequence"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    ExpSequence(
      NodeChild.seq_with[Expression](expressions, old_children, new_children)?)

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("expressions", Nodes.get_json(expressions)))
