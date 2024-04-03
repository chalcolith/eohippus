use json = "../json"

primitive IfExp
primitive IfDef
primitive IfType

type IfKind is (IfExp | IfDef | IfType)

class val ExpIf is NodeData
  """
    An `if` expression.
    - `kind`: `if`, `ifdef`, or `iftype`.
  """

  let kind: IfKind
  let conditions: NodeSeqWith[IfCondition]
  let else_block: (NodeWith[Expression] | None)

  new val create(
    kind': IfKind,
    conditions': NodeSeqWith[IfCondition],
    else_block': (NodeWith[Expression] | None))
  =>
    kind = kind'
    conditions = conditions'
    else_block = else_block'

  fun name(): String => "ExpIf"

  fun val clone(updates: ChildUpdateMap): ExpIf =>
    ExpIf(
      kind,
      _map[IfCondition](conditions, updates),
      _map_or_none[Expression](else_block, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    let kind_str =
      match kind
      | IfExp => "IfExp"
      | IfDef => "IfDef"
      | IfType => "IfType"
      end
    props.push(("kind", kind_str))
    props.push(("conditions", node.child_refs(conditions)))
    match else_block
    | let block: Node =>
      props.push(("else_block", node.child_ref(block)))
    end

class val IfCondition is NodeData
  """
    A condition and then-block in an `if` expression (i.e. the initial `if` and
    `then` block; or subsequent `elseif` and `then` blocks).
  """
  let if_true: NodeWith[Expression]
  let then_block: NodeWith[Expression]

  new val create(
    if_true': NodeWith[Expression],
    then_block': NodeWith[Expression])
  =>
    if_true = if_true'
    then_block = then_block'

  fun name(): String => "IfCondition"

  fun val clone(updates: ChildUpdateMap): IfCondition =>
    IfCondition(
      _map_with[Expression](if_true, updates),
      _map_with[Expression](then_block, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("if_true", node.child_ref(if_true)))
    props.push(("then_block", node.child_ref(then_block)))
