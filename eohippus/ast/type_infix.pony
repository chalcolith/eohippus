use json = "../json"

class val TypeInfix is NodeData
  let types: NodeSeqWith[TypeType]
  let op: (NodeWith[Token] | None)

  new val create(
    types': NodeSeqWith[TypeType],
    op': (NodeWith[Token] | None))
  =>
    types = types'
    op = op'

  fun name(): String => "TypeInfix"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    TypeInfix(
      NodeChild.seq_with[TypeType](types, old_children, new_children)?,
      NodeChild.with_or_none[Token](op, old_children, new_children)?)

  fun add_json_props(props: Array[(String, json.Item)]) =>
    match op
    | let op': NodeWith[Token] =>
      props.push(("op", op'.get_json()))
    end
    if types.size() > 0 then
      props.push(("types", Nodes.get_json(types)))
    end
