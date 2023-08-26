use "itertools"

use json = "../json"
use types = "../types"

class val ExpSequence is NodeData
  let expressions: NodeSeq

  new create(expressions': NodeSeq) =>
    expressions = expressions'

  fun name(): String => "ExpSequence"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("expressions", Nodes.get_json(expressions)))
