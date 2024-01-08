
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

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    CallArgs(
      _child_seq_with[Expression](pos, old_children, new_children)?,
      _child_seq_with[Expression](named, old_children, new_children)?)

  fun add_json_props(props: Array[(String, json.Item)]) =>
    if pos.size() > 0 then
      props.push(("positional", Nodes.get_json(pos)))
    end
    if named.size() > 0 then
      props.push(("named", Nodes.get_json(named)))
    end
