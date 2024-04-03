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

  fun val clone(updates: ChildUpdateMap): ExpFor =>
    ExpFor(
      _map_with[TuplePattern](pattern, updates),
      _map_with[Expression](sequence, updates),
      _map_with[Expression](body, updates),
      _map_or_none[Expression](else_block, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("pattern", node.child_ref(pattern)))
    props.push(("sequence", node.child_ref(sequence)))
    props.push(("body", node.child_ref(body)))
    match else_block
    | let else_block': NodeWith[Expression] =>
      props.push(("else_block", node.child_ref(else_block')))
    end
