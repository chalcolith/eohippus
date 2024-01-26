use json = "../json"

class val TypeAtom is NodeData
  """A basic type (usually an identifier)."""

  let body: Node

  new val create(body': Node) =>
    body = body'

  fun name(): String => "TypeAtom"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    TypeAtom(NodeChild(body, old_children, new_children)?)

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("body", body.get_json()))
