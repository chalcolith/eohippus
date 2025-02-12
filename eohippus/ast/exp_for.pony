use json = "../json"

class val ExpFor is NodeData
  """
    A `for` loop.
  """

  let pattern: NodeWith[TuplePattern]
  let sequence: NodeWith[Expression]
  let body: NodeWith[Expression]
  let else_block: (NodeWith[Expression] | None)

  new val create(
    pattern': NodeWith[TuplePattern],
    sequence': NodeWith[Expression],
    body': NodeWith[Expression],
    else_block': (NodeWith[Expression] | None))
  =>
    pattern = pattern'
    sequence = sequence'
    body = body'
    else_block = else_block'

  fun name(): String => "ExpFor"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    ExpFor(
      _map_with[TuplePattern](pattern, updates),
      _map_with[Expression](sequence, updates),
      _map_with[Expression](body, updates),
      _map_or_none[Expression](else_block, updates))

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    props.push(("pattern", node.child_ref(pattern)))
    props.push(("sequence", node.child_ref(sequence)))
    props.push(("body", node.child_ref(body)))
    match else_block
    | let else_block': NodeWith[Expression] =>
      props.push(("else_block", node.child_ref(else_block')))
    end

primitive ParseExpFor
  fun apply(obj: json.Object val, children: NodeSeq): (ExpFor | String) =>
    let pattern =
      match ParseNode._get_child_with[TuplePattern](
        obj,
        children,
        "pattern",
        "ExpFor.pattern must be a TuplePattern")
      | let node: NodeWith[TuplePattern] =>
        node
      | let err: String =>
        return err
      else
        return "ExpFor.pattern must be a TuplePattern"
      end
    let sequence =
      match ParseNode._get_child_with[Expression](
        obj,
        children,
        "sequence",
        "ExpFor.sequence must be an Expression")
      | let node: NodeWith[Expression] =>
        node
      | let err: String =>
        return err
      else
        return "ExpFor.sequence must be an Expression"
      end
    let body =
      match ParseNode._get_child_with[Expression](
        obj,
        children,
        "body",
        "ExpFor.body must be an Expression")
      | let node: NodeWith[Expression] =>
        node
      | let err: String =>
        return err
      else
        return "ExpFor.body must be an Expression"
      end
    let else_block =
      match ParseNode._get_child_with[Expression](
        obj,
        children,
        "else_block",
        "ExpFor.else_block must be an Expression",
        false)
      | let node: NodeWith[Expression] =>
        node
      | let err: String =>
        return err
      end
    ExpFor(pattern, sequence, body, else_block)
