use "itertools"

use json = "../json"

class val ExpSequence is NodeData
  """A sequence of expressions, possibly separated by semicolons."""

  let expressions: NodeSeqWith[Expression]

  new val create(expressions': NodeSeqWith[Expression]) =>
    expressions = expressions'

  fun name(): String => "ExpSequence"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    ExpSequence(_map[Expression](expressions, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("expressions", node.child_refs(expressions)))
