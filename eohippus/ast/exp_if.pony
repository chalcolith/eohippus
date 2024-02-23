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

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    ExpIf(
      kind,
      NodeChild.seq_with[IfCondition](conditions, old_children, new_children)?,
      NodeChild.with_or_none[Expression](else_block, old_children, new_children)?)

  fun add_json_props(
    props: Array[(String, json.Item)],
    lines_and_columns: (LineColumnMap | None) = None)
  =>
    let kind_str =
      match kind
      | IfExp => "IfExp"
      | IfDef => "IfDef"
      | IfType => "IfType"
      end
    props.push(("kind", kind_str))
    props.push(("conditions", Nodes.get_json(conditions, lines_and_columns)))
    match else_block
    | let block: Node =>
      props.push(("else_block", block.get_json(lines_and_columns)))
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

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    IfCondition(
      NodeChild.child_with[Expression](if_true, old_children, new_children)?,
      NodeChild.child_with[Expression](then_block, old_children, new_children)?)

  fun add_json_props(
    props: Array[(String, json.Item)],
    lines_and_columns: (LineColumnMap | None) = None)
  =>
    props.push(("if_true", if_true.get_json(lines_and_columns)))
    props.push(("then_block", then_block.get_json(lines_and_columns)))
