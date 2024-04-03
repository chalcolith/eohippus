use json = "../json"

class val DocString is NodeData
  """Represents a doc string."""

  let string: NodeWith[Literal]

  new val create(string': NodeWith[Literal]) =>
    string = string'

  fun name(): String => "DocString"

  fun val clone(updates: ChildUpdateMap): DocString =>
    DocString(try updates(string)? as NodeWith[Literal] else string end)

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("string", node.child_ref(string)))
