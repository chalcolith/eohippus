use json = "../json"

class val TypeAtom is NodeData
  let body: Node

  new val create(body': Node) =>
    body = body'

  fun name(): String => "TypeAtom"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("body", body.get_json()))
