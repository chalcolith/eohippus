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
  let pattern: NodeWith[TuplePattern]
  let body: NodeWith[Expression]

  new val create(
    pattern': NodeWith[TuplePattern],
    body': NodeWith[Expression])
  =>
    pattern = pattern'
    body = body'

  fun name(): String => "WithElement"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("pattern", pattern.get_json()))
    props.push(("body", body.get_json()))
