use json = "../json"

class val ExpOperation is NodeData
  let lhs:
    ( NodeWith[TypeType]
    | NodeWith[Expression]
    | NodeWith[Identifier]
    | None)
  let op: (NodeWith[Keyword] | NodeWith[Token])
  let rhs: (NodeWith[TypeType] | NodeWith[Expression] | NodeWith[Identifier])
  let partial: Bool

  new val create(
    lhs':
      ( NodeWith[TypeType]
      | NodeWith[Expression]
      | NodeWith[Identifier]
      | None),
    op': (NodeWith[Keyword] | NodeWith[Token]),
    rhs': (NodeWith[TypeType] | NodeWith[Expression] | NodeWith[Identifier]),
    partial': Bool = false)
  =>
    lhs = lhs'
    op = op'
    rhs = rhs'
    partial = partial'

  fun name(): String => "ExpOperation"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    match lhs
    | let lhs': Node =>
      props.push(("lhs", lhs'.get_json()))
    end
    props.push(("op", op.get_json()))
    props.push(("rhs", rhs.get_json()))
    if partial then
      props.push(("partial", partial))
    end
