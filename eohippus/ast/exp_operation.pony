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

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    let lhs' =
      match lhs
      | let lhs_type: NodeWith[TypeType] =>
        _child_with[TypeType](lhs_type, old_children, new_children)?
      | let lhs_exp: NodeWith[Expression] =>
        _child_with[Expression](lhs_exp, old_children, new_children)?
      | let lhs_id: NodeWith[Identifier] =>
        _child_with[Identifier](lhs_id, old_children, new_children)?
      end
    let op' =
      match op
      | let op_kw: NodeWith[Keyword] =>
        _child_with[Keyword](op_kw, old_children, new_children)?
      | let op_tok: NodeWith[Token] =>
        _child_with[Token](op_tok, old_children, new_children)?
      end
    let rhs' =
      match rhs
      | let rhs_type: NodeWith[TypeType] =>
        _child_with[TypeType](rhs_type, old_children, new_children)?
      | let rhs_exp: NodeWith[Expression] =>
        _child_with[Expression](rhs_exp, old_children, new_children)?
      | let rhs_id: NodeWith[Identifier] =>
        _child_with[Identifier](rhs_id, old_children, new_children)?
      end

    ExpOperation(
      lhs',
      op',
      rhs',
      partial)

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
