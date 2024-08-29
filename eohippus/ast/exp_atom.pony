
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

  fun val clone(updates: ChildUpdateMap): NodeData =>
    ExpAtom(try updates(body)? else body end)

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    props.push(("body", node.child_ref(body)))

primitive ParseExpAtom
  fun apply(obj: json.Object, children: NodeSeq): (ExpAtom | String) =>
    let body =
      match ParseNode._get_child(
        obj,
        children,
        "body",
        "ExpAtom.body must be a Node")
      | let node: Node =>
        node
      | let err: String =>
        return err
      else
        return "ExpAtom.body must be a Node"
      end
    ExpAtom(body)
