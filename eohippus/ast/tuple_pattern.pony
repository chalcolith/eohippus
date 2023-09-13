use json = "../json"

class val TuplePattern is NodeData
  let ids: ReadSeq[(NodeWith[Identifier] | NodeWith[TuplePattern])] val

  new val create(
    ids': ReadSeq[(NodeWith[Identifier] | NodeWith[TuplePattern])] val)
  =>
    ids = ids'

  fun name(): String => "TuplePattern"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    if ids.size() > 0 then
      props.push(("ids", Nodes.get_json(ids)))
    end
