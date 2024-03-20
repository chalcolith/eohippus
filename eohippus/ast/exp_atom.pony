
use json = "../json"

class val ExpAtom is NodeData
  """
    A simple expression; can contain an identifier, a literal, a parenthesized
    expression or a control structure.
  """

  let body: Node

  new val create(body': Node) =>
    body = body'

  fun name(): String => "ExpAtom"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    ExpAtom(NodeChild(body, old_children, new_children)?)

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("body", node.child_ref(body)))
