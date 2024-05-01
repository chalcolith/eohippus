
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

  fun val clone(updates: ChildUpdateMap): NodeData =>
    CallArgs(_map[Expression](pos, updates), _map[Expression](named, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    if pos.size() > 0 then
      props.push(("positional", node.child_refs(pos)))
    end
    if named.size() > 0 then
      props.push(("named", node.child_refs(named)))
    end

primitive ParseCallArgs
  fun apply(obj: json.Object, children: NodeSeq): (CallArgs | String) =>
    let positional =
      match ParseNode._get_seq_with[Expression](
        obj,
        children,
        "positional",
        "CallArgs.positional must refer to Expressions")
      | let seq: NodeSeqWith[Expression] =>
        seq
      | let err: String =>
        return err
      end
    let named =
      match ParseNode._get_seq_with[Expression](
        obj,
        children,
        "named",
        "CallArgs.named must refer to Expressions")
      | let seq: NodeSeqWith[Expression] =>
        seq
      | let err: String =>
        return err
      end
    CallArgs(positional, named)
