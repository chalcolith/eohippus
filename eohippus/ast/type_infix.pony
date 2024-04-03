use json = "../json"

class val TypeInfix is NodeData
  """
    An algebraic type expression.
    - `op`: `&` or `|`.
  """

  let types: NodeSeqWith[TypeType]
  let op: (NodeWith[Token] | None)

  new val create(
    types': NodeSeqWith[TypeType],
    op': (NodeWith[Token] | None))
  =>
    types = types'
    op = op'

  fun name(): String => "TypeInfix"

  fun val clone(updates: ChildUpdateMap): TypeInfix =>
    TypeInfix(_map[TypeType](types, updates), _map_or_none[Token](op, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    match op
    | let op': NodeWith[Token] =>
      props.push(("op", node.child_ref(op')))
    end
    if types.size() > 0 then
      props.push(("types", node.child_refs(types)))
    end
