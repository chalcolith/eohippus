use json = "../json"

class val ExpJump is NodeData
  let keyword: NodeWith[Keyword]
  let rhs: (NodeWith[Expression] | None)

  new val create(
    keyword': NodeWith[Keyword],
    rhs': (NodeWith[Expression] | None))
  =>
    keyword = keyword'
    rhs = rhs'

  fun name(): String => "ExpJump"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("keyword", keyword.get_json()))
    match rhs
    | let rhs': Node =>
      props.push(("rhs", rhs'.get_json()))
    end
