use json = "../json"

class val DocString is NodeData
  let string: NodeWith[Literal]

  new val create(string': NodeWith[Literal]) =>
    string = string'

  fun name(): String => "DocString"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    DocString(_child_with[Literal](string, old_children, new_children)?)

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("string", string.get_json()))
