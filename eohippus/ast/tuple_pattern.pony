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

  fun val clone(updates: ChildUpdateMap): NodeData =>
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

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    if elements.size() > 0 then
      props.push(("elements", node.child_refs(elements)))
    end

primitive ParseTuplePattern
  fun _help(): String => "TuplePattern.elements must be a sequence of " +
    "(Identifier | TuplePattern)"

  fun apply(obj: json.Object, children: NodeSeq): (TuplePattern | String) =>
    let elements: Array[(NodeWith[Identifier] | NodeWith[TuplePattern])] trn =
      Array[(NodeWith[Identifier] | NodeWith[TuplePattern])]
    match try obj("elements")? end
    | let seq: json.Sequence =>
      for item in seq.values() do
        match item
        | let i: I128 =>
          try
            elements.push(children(USize.from[I128](i))? as
              (NodeWith[Identifier] | NodeWith[TuplePattern]))
          else
            return _help()
          end
        else
          return _help()
        end
      end
    else
      return _help()
    end
    TuplePattern(consume elements)
