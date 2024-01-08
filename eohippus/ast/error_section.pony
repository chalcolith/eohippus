use json = "../json"

class val ErrorSection is NodeData
  let message: String

  new val create(message': String) =>
    message = message'

  fun name(): String => "ErrorSection"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData =>
    this

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("message", message))
