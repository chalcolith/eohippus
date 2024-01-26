use json = "../json"

class val TuplePattern is NodeData
  """
    A matching pattern for (possible) tuples.
  """

  let ids: ReadSeq[(NodeWith[Identifier] | NodeWith[TuplePattern])] val

  new val create(
    ids': ReadSeq[(NodeWith[Identifier] | NodeWith[TuplePattern])] val)
  =>
    ids = ids'

  fun name(): String => "TuplePattern"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    let result: Array[(NodeWith[Identifier] | NodeWith[TuplePattern])] trn =
      Array[(NodeWith[Identifier] | NodeWith[TuplePattern])](ids.size())
    for old_child in ids.values() do
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

  fun add_json_props(props: Array[(String, json.Item)]) =>
    if ids.size() > 0 then
      props.push(("ids", Nodes.get_json(ids)))
    end
