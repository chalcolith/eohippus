use "itertools"

use json = "../json"

class val ExpSequence is NodeData
  let expressions: NodeSeqWith[Expression]

  new val create(expressions': NodeSeqWith[Expression]) =>
    expressions = expressions'

  fun name(): String => "ExpSequence"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("expressions", Nodes.get_json(expressions)))
