
use json = "../json"

class val CallArgs is NodeData
  let pos: NodeSeqWith[ExpSequence]
  let named: NodeSeqWith[ExpOperation]

  new val create(
    pos': NodeSeqWith[ExpSequence],
    named': NodeSeqWith[ExpOperation])
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
