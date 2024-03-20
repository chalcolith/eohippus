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

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    ExpJump(
      NodeChild.child_with[Keyword](keyword, old_children, new_children)?,
      NodeChild.with_or_none[Expression](rhs, old_children, new_children)?)

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("keyword", node.child_ref(keyword)))
    match rhs
    | let rhs': Node =>
      props.push(("rhs", node.child_ref(rhs')))
    end
