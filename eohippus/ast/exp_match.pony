use json = "../json"

class val ExpMatch is NodeData
  """A `match` expression."""
  let expression: NodeWith[Expression]
  let cases: NodeSeqWith[MatchCase]
  let else_block: (NodeWith[Expression] | None)

  new val create(
    expression': NodeWith[Expression],
    cases': NodeSeqWith[MatchCase],
    else_block': (NodeWith[Expression] | None))
  =>
    expression = expression'
    cases = cases'
    else_block = else_block'

  fun name(): String => "ExpMatch"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    ExpMatch(
      _map_with[Expression](expression, updates),
      _map[MatchCase](cases, updates),
      _map_or_none[Expression](else_block, updates))

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    props.push(("expression", node.child_ref(expression)))
    if cases.size() > 0 then
      props.push(("cases", node.child_refs(cases)))
    end
    match else_block
    | let else_block': NodeWith[Expression] =>
      props.push(("else_block", node.child_ref(else_block')))
    end

primitive ParseExpMatch
  fun apply(obj: json.Object, children: NodeSeq): (ExpMatch | String) =>
    let expression =
      match ParseNode._get_child_with[Expression](
        obj,
        children,
        "expression",
        "ExpMatch.expression must be an Expression")
      | let node: NodeWith[Expression] =>
        node
      | let err: String =>
        return err
      else
        return "ExpMatch.expression must be an Expression"
      end
    let cases =
      match ParseNode._get_seq_with[MatchCase](
        obj,
        children,
        "cases",
        "ExpMatch.cases must be a list of MatchCase")
      | let seq: NodeSeqWith[MatchCase] =>
        seq
      | let err: String =>
        return err
      end
    let else_block =
      match ParseNode._get_child_with[Expression](
        obj,
        children,
        "else_block",
        "ExpMatch.else_block must be an Expression",
        false)
      | let node: NodeWith[Expression] =>
        node
      | let err: String =>
        return err
      end
    ExpMatch(expression, cases, else_block)

class val MatchCase is NodeData
  """A case in a `match` expression."""
  let pattern: NodeWith[Expression]
  let condition: (NodeWith[Expression] | None)
  let body: NodeWith[Expression]

  new val create(
    pattern': NodeWith[Expression],
    condition': (NodeWith[Expression] | None),
    body': NodeWith[Expression])
  =>
    pattern = pattern'
    condition = condition'
    body = body'

  fun name(): String => "MatchCase"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    MatchCase(
      _map_with[Expression](pattern, updates),
      _map_or_none[Expression](condition, updates),
      _map_with[Expression](body, updates))

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    props.push(("pattern", node.child_ref(pattern)))
    match condition
    | let condition': NodeWith[Expression] =>
      props.push(("condition", node.child_ref(condition')))
    end
    props.push(("body", node.child_ref(body)))

primitive ParseMatchCase
  fun apply(obj: json.Object, children: NodeSeq): (MatchCase | String) =>
    let pattern =
      match ParseNode._get_child_with[Expression](
        obj,
        children,
        "pattern",
        "MatchCase.pattern must be an Expression")
      | let node: NodeWith[Expression] =>
        node
      | let err: String =>
        return err
      else
        return "MatchCase.pattern must be an Expression"
      end
    let condition =
      match ParseNode._get_child_with[Expression](
        obj,
        children,
        "condition",
        "MatchCase.condition must be an Expression",
        false)
      | let node: NodeWith[Expression] =>
        node
      | let err: String =>
        return err
      end
    let body =
      match ParseNode._get_child_with[Expression](
        obj,
        children,
        "body",
        "MatchCase.body must be an Expression")
      | let node: NodeWith[Expression] =>
        node
      | let err: String =>
        return err
      else
        return "MatchCase.body must be an Expression"
      end
    MatchCase(pattern, condition, body)
