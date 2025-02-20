use json = "../json"

class val ExpOperation is NodeData
  """A binary infix operation expression, or a unary prefix operation."""

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

  fun val clone(updates: ChildUpdateMap): NodeData =>
    let lhs' =
      match lhs
      | let lhs_type: NodeWith[TypeType] =>
        _map_with[TypeType](lhs_type, updates)
      | let lhs_exp: NodeWith[Expression] =>
        _map_with[Expression](lhs_exp, updates)
      | let lhs_id: NodeWith[Identifier] =>
        _map_with[Identifier](lhs_id, updates)
      end
    let op' =
      match op
      | let op_kw: NodeWith[Keyword] =>
        _map_with[Keyword](op_kw, updates)
      | let op_tok: NodeWith[Token] =>
        _map_with[Token](op_tok, updates)
      end
    let rhs' =
      match rhs
      | let rhs_type: NodeWith[TypeType] =>
        _map_with[TypeType](rhs_type, updates)
      | let rhs_exp: NodeWith[Expression] =>
        _map_with[Expression](rhs_exp, updates)
      | let rhs_id: NodeWith[Identifier] =>
        _map_with[Identifier](rhs_id, updates)
      end
    ExpOperation(lhs', op', rhs', partial)

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    match lhs
    | let lhs': Node =>
      props.push(("lhs", node.child_ref(lhs')))
    end
    props.push(("op", node.child_ref(op)))
    props.push(("rhs", node.child_ref(rhs)))
    if partial then
      props.push(("partial", partial))
    end

primitive ParseExpOperation
  fun apply(obj: json.Object val, children: NodeSeq): (ExpOperation | String) =>
    let lhs =
      match ParseNode._get_child(
        obj,
        children,
        "lhs",
        "ExpOperation.lhs must be (TypeType | Expression | Identifier)",
        false)
      | let tt: NodeWith[TypeType] =>
        tt
      | let ex: NodeWith[Expression] =>
        ex
      | let id: NodeWith[Identifier] =>
        id
      | let err: String =>
        return err
      end
    let op =
      match ParseNode._get_child(
        obj,
        children,
        "op",
        "ExpOperation.op must be (Keyword | Token)")
      | let kw: NodeWith[Keyword] =>
        kw
      | let tk: NodeWith[Token] =>
        tk
      | let err: String =>
        return err
      else
        return "ExpOperation.op must be (Keyword | Token)"
      end
    let rhs =
      match ParseNode._get_child(
        obj,
        children,
        "rhs",
        "ExpOperation.rhs must be (TypeType | Expression | Identifier)")
      | let tt: NodeWith[TypeType] =>
        tt
      | let ex: NodeWith[Expression] =>
        ex
      | let id: NodeWith[Identifier] =>
        id
      | let err: String =>
        return err
      else
        return "ExpOperation.rhs must be (TypeType | Expression | Identifier)"
      end
    let partial =
      match try obj("partial")? end
      | let bool: Bool =>
        bool
      | let item: json.Item =>
        return "ExpOperation.partial must be a boolean"
      else
        false
      end
    ExpOperation(lhs, op, rhs, partial)
