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

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    props.push(("keyword", node.child_ref(keyword)))
    match rhs
    | let rhs': Node =>
      props.push(("rhs", node.child_ref(rhs')))
    end

primitive ParseExpJump
  fun apply(obj: json.Object, children: NodeSeq): (ExpJump | String) =>
    let keyword =
      match ParseNode._get_child_with[Keyword](
        obj,
        children,
        "keyword",
        "ExpJump.keyword must be a Keyword")
      | let node: NodeWith[Keyword] =>
        node
      | let err: String =>
        return err
      else
        return "ExpJump.keyword must be a Keyword"
      end
    let rhs =
      match ParseNode._get_child_with[Expression](
        obj,
        children,
        "rhs",
        "ExpJump.rhs must be an Expression",
        false)
      | let node: NodeWith[Expression] =>
        node
      | let err: String =>
        return err
      end
    ExpJump(keyword, rhs)
