use json = "../json"

class val DocString is NodeData
  """Represents a doc string."""

  let string: NodeWith[Literal]

  new val create(string': NodeWith[Literal]) =>
    string = string'

  fun name(): String => "DocString"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    DocString(
      NodeChild.child_with[Literal](string, old_children, new_children)?)

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("string", node.child_ref(string)))
