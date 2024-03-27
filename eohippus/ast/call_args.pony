
use json = "../json"

class val CallArgs is NodeData
  """
    The arguments (actual parameters) of a method call.
    - `pos`: positional arguments.
    - `named`: named arguments (should all be assignment expressions).
  """

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
      NodeChild.seq_with[Expression](pos, old_children, new_children)?,
      NodeChild.seq_with[Expression](named, old_children, new_children)?)

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    if pos.size() > 0 then
      props.push(("positional", node.child_refs(pos)))
    end
    if named.size() > 0 then
      props.push(("named", node.child_refs(named)))
    end
