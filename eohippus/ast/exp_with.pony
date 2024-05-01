use json = "../json"

class val ExpWith is NodeData
  """A `with` block."""

  let elements: NodeSeqWith[WithElement]
  let body: NodeWith[Expression]

  new val create(
    elements': NodeSeqWith[WithElement],
    body': NodeWith[Expression])
  =>
    elements = elements'
    body = body'

  fun name(): String => "ExpWith"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    ExpWith(
      _map[WithElement](elements, updates),
      _map_with[Expression](body, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    if elements.size() > 0 then
      props.push(("elements", node.child_refs(elements)))
    end
    props.push(("body", node.child_ref(body)))

primitive ParseExpWith
  fun apply(obj: json.Object, children: NodeSeq): (ExpWith | String) =>
    let elements =
      match ParseNode._get_seq_with[WithElement](
        obj,
        children,
        "elements",
        "ExpWith.elements must be a sequence of WithElement",
        false)
      | let seq: NodeSeqWith[WithElement] =>
        seq
      | let err: String =>
        return err
      end
    let body =
      match ParseNode._get_child_with[Expression](
        obj,
        children,
        "body",
        "ExpWith.body must be an Expression")
      | let node: NodeWith[Expression] =>
        node
      | let err: String =>
        return err
      else
        return "ExpWith.body must be an Expression"
      end
    ExpWith(elements, body)

class val WithElement is NodeData
  """An arm of a `with` expression."""

  let pattern: NodeWith[TuplePattern]
  let body: NodeWith[Expression]

  new val create(
    pattern': NodeWith[TuplePattern],
    body': NodeWith[Expression])
  =>
    pattern = pattern'
    body = body'

  fun name(): String => "WithElement"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    WithElement(
      _map_with[TuplePattern](pattern, updates),
      _map_with[Expression](body, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("pattern", node.child_ref(pattern)))
    props.push(("body", node.child_ref(body)))

primitive ParseWithElement
  fun apply(obj: json.Object, children: NodeSeq): (WithElement | String) =>
    let pattern =
      match ParseNode._get_child_with[TuplePattern](
        obj,
        children,
        "pattern",
        "WithElement.pattern must be a TuplePattern")
      | let node: NodeWith[TuplePattern] =>
        node
      | let err: String =>
        return err
      else
        return "WithElement.pattern must be a TuplePattern"
      end
    let body =
      match ParseNode._get_child_with[Expression](
        obj,
        children,
        "body",
        "WithElement.body must be an Expression")
      | let node: NodeWith[Expression] =>
        node
      | let err: String =>
        return err
      else
        return "WithElement.body must be an Expression"
      end
    WithElement(pattern, body)
