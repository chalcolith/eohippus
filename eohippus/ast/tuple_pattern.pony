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

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    let result: Array[(NodeWith[Identifier] | NodeWith[TuplePattern])] trn =
      Array[(NodeWith[Identifier] | NodeWith[TuplePattern])](elements.size())
    for old_child in elements.values() do
      var i: USize = 0
      while i < old_children.size() do
        if old_child is old_children(i)? then
          result.push(new_children(i)? as
            (NodeWith[Identifier] | NodeWith[TuplePattern]))
          break
        end
        i = i + 1
      end
      if i == old_children.size() then error end
    end
    TuplePattern(consume result)

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    if elements.size() > 0 then
      props.push(("elements", node.child_refs(elements)))
    end
