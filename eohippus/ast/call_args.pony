
use json = "../json"

class val CallArgs is NodeData
  let pos: NodeSeqWith[Expression]
  let named: NodeSeqWith[Expression]

  new val create(
    pos': NodeSeqWith[Expression],
    named': NodeSeqWith[Expression])
  =>
    pos = pos'
    named = named'

  fun name(): String => "CallArgs"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    if pos.size() > 0 then
      props.push(("positional", Nodes.get_json(pos)))
    end
    if named.size() > 0 then
      props.push(("named", Nodes.get_json(named)))
    end
