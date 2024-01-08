use json = "../json"

class val TypeArrow is NodeData
  let lhs: Node
  let rhs: (NodeWith[TypeType] | None)

  new val create(lhs': Node, rhs': (NodeWith[TypeType] | None)) =>
    lhs = lhs'
    rhs = rhs'

  fun name(): String => "TypeArrow"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    TypeArrow(
      _child(lhs, old_children, new_children)?,
      _child_with_or_none[TypeType](rhs, old_children, new_children)?)

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("lhs", lhs.get_json()))
    match rhs
    | let rhs': NodeWith[TypeType] =>
      props.push(("rhs", rhs'.get_json()))
    end
