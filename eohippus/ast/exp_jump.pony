use json = "../json"

class val ExpJump is NodeData
  """
    A jump.
    - `keyword`: `return`, `break`, `continue`, `error`, `compile_intrinsic`
      or `compile_error`.
  """

  let keyword: NodeWith[Keyword]
  let rhs: (NodeWith[Expression] | None)

  new val create(
    keyword': NodeWith[Keyword],
    rhs': (NodeWith[Expression] | None))
  =>
    keyword = keyword'
    rhs = rhs'

  fun name(): String => "ExpJump"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    ExpJump(
      _map_with[Keyword](keyword, updates),
      _map_or_none[Expression](rhs, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("keyword", node.child_ref(keyword)))
    match rhs
    | let rhs': Node =>
      props.push(("rhs", node.child_ref(rhs')))
    end
