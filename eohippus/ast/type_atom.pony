use json = "../json"

class val TypeAtom is NodeData
  """A basic type (usually an identifier)."""

  let body: Node

  new val create(body': Node) =>
    body = body'

  fun name(): String => "TypeAtom"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    TypeAtom(try updates(body)? else body end)

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    props.push(("body", node.child_ref(body)))

primitive ParseTypeAtom
  fun apply(obj: json.Object, children: NodeSeq): (TypeAtom | String) =>
    let body =
      match ParseNode._get_child(
        obj,
        children,
        "body",
        "TypeAtom.body must be a Node")
      | let node: Node =>
        node
      | let err: String =>
        return err
      else
        return "TypeAtom.body must be a Node"
      end
    TypeAtom(body)
