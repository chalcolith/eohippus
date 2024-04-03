use json = "../json"

class val TypeNominal is NodeData
  """A (possibly qualified) named type, with optional type parameters."""

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

  fun val clone(updates: ChildUpdateMap): TypeNominal =>
    TypeNominal(
      _map_or_none[Identifier](lhs, updates),
      _map_with[Identifier](rhs, updates),
      _map_or_none[TypeParams](params, updates),
      _map_or_none[Keyword](cap, updates),
      _map_or_none[Token](eph, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    match lhs
    | let lhs': NodeWith[Identifier] =>
      props.push(("lhs", node.child_ref(lhs')))
    end
    props.push(("rhs", node.child_ref(rhs)))
    match params
    | let params': NodeWith[TypeParams] =>
      if params'.data().params.size() > 0 then
        props.push(("params", node.child_ref(params')))
      end
    end
    match cap
    | let cap': NodeWith[Keyword] =>
      props.push(("cap", node.child_ref(cap')))
    end
    match eph
    | let eph': NodeWith[Token] =>
      props.push(("eph", node.child_ref(eph')))
    end
