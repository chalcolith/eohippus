
use json = "../json"

class val ExpAtom is NodeData
  let body: Node

  new val create(body': Node) =>
    body = body'

  fun name(): String => "ExpAtom"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    ExpAtom(NodeChild(body, old_children, new_children)?)

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("body", body.get_json()))
