use json = "../json"

class val TypeAtom is NodeData
  """A basic type (usually an identifier)."""

  let body: Node

  new val create(body': Node) =>
    body = body'

  fun name(): String => "TypeAtom"

  fun val clone(updates: ChildUpdateMap): TypeAtom =>
    TypeAtom(try updates(body)? else body end)

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("body", node.child_ref(body)))
