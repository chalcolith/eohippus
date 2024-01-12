use json = "../json"

class val TypeNominal is NodeData
  let lhs: (NodeWith[Identifier] | None)
  let rhs: NodeWith[Identifier]
  let params: (NodeWith[TypeParams] | None)
  let cap: (NodeWith[Keyword] | None)
  let eph: (NodeWith[Token] | None)

  new val create(
    lhs': (NodeWith[Identifier] | None),
    rhs': NodeWith[Identifier],
    params': (NodeWith[TypeParams] | None),
    cap': (NodeWith[Keyword] | None),
    eph': (NodeWith[Token] | None))
  =>
    lhs = lhs'
    rhs = rhs'
    params = params'
    cap = cap'
    eph = eph'

  fun name(): String => "TypeNominal"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    TypeNominal(
      NodeChild.with_or_none[Identifier](lhs, old_children, new_children)?,
      NodeChild.child_with[Identifier](rhs, old_children, new_children)?,
      NodeChild.with_or_none[TypeParams](params, old_children, new_children)?,
      NodeChild.with_or_none[Keyword](cap, old_children, new_children)?,
      NodeChild.with_or_none[Token](eph, old_children, new_children)?)

  fun add_json_props(props: Array[(String, json.Item)]) =>
    match lhs
    | let lhs': NodeWith[Identifier] =>
      props.push(("lhs", lhs'.get_json()))
    end
    props.push(("rhs", rhs.get_json()))
    match params
    | let params': NodeWith[TypeParams] =>
      if params'.data().params.size() > 0 then
        props.push(("params", params'.get_json()))
      end
    end
    match cap
    | let cap': NodeWith[Keyword] =>
      props.push(("cap", cap'.get_json()))
    end
    match eph
    | let eph': NodeWith[Token] =>
      props.push(("eph", eph'.get_json()))
    end
