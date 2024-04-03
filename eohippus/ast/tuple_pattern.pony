use json = "../json"

class val TuplePattern is NodeData
  """
    A matching pattern for (possible) tuples.
  """

  let elements: ReadSeq[(NodeWith[Identifier] | NodeWith[TuplePattern])] val

  new val create(
    elements': ReadSeq[(NodeWith[Identifier] | NodeWith[TuplePattern])] val)
  =>
    elements = elements'

  fun name(): String => "TuplePattern"

  fun val clone(updates: ChildUpdateMap): TuplePattern =>
    let result: Array[(NodeWith[Identifier] | NodeWith[TuplePattern])] trn =
      Array[(NodeWith[Identifier] | NodeWith[TuplePattern])](elements.size())
    for old_child in elements.values() do
      try
        result.push(
          updates(old_child)?
            as (NodeWith[Identifier] | NodeWith[TuplePattern]))
      end
    end
    TuplePattern(consume result)

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    if elements.size() > 0 then
      props.push(("elements", node.child_refs(elements)))
    end
