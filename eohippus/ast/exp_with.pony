use json = "../json"

class val ExpWith is NodeData
  let elements: NodeSeqWith[WithElement]
  let body: NodeWith[Expression]

  new val create(
    elements': NodeSeqWith[WithElement],
    body': NodeWith[Expression])
  =>
    elements = elements'
    body = body'

  fun name(): String => "ExpWith"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    if elements.size() > 0 then
      props.push(("elements", Nodes.get_json(elements)))
    end
    props.push(("body", body.get_json()))

class val WithElement is NodeData
  let ids: NodeSeqWith[Identifier]
  let body: NodeWith[Expression]

  new val create(ids': NodeSeqWith[Identifier], body': NodeWith[Expression]) =>
    ids = ids'
    body = body'

  fun name(): String => "WithElement"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    if ids.size() > 0 then
      props.push(("ids", Nodes.get_json(ids)))
    end
    props.push(("body", body.get_json()))
