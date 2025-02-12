use json = "../json"

class val DocString is NodeData
  """Represents a doc string."""

  let string: NodeWith[LiteralString]

  new val create(string': NodeWith[LiteralString]) =>
    string = string'

  fun name(): String => "DocString"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    DocString(try updates(string)? as NodeWith[LiteralString] else string end)

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    props.push(("string", node.child_ref(string)))

primitive ParseDocString
  fun apply(obj: json.Object val, children: NodeSeq): (DocString | String) =>
    let string =
      match ParseNode._get_child_with[LiteralString](
        obj,
        children,
        "string",
        "DocString.string must be a LiteralString")
      | let string': NodeWith[LiteralString] =>
        string'
      | let err: String =>
        return err
      else
        return "DocString.string must be a LiteralString"
      end
    DocString(string)
