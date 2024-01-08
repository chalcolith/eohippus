use json = "../json"

primitive IfExp
primitive IfDef
primitive IfType

type IfKind is (IfExp | IfDef | IfType)

class val ExpIf is NodeData
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
      _child_seq_with[IfCondition](conditions, old_children, new_children)?,
      _child_with_or_none[Expression](else_block, old_children, new_children)?)

  fun add_json_props(props: Array[(String, json.Item)]) =>
    let kind_str =
      match kind
      | IfExp => "IfExp"
      | IfDef => "IfDef"
      | IfType => "IfType"
      end
    props.push(("kind", kind_str))
    props.push(("conditions", Nodes.get_json(conditions)))
    match else_block
    | let block: Node =>
      props.push(("else_block", block.get_json()))
    end

class val IfCondition is NodeData
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
      _child_with[Expression](if_true, old_children, new_children)?,
      _child_with[Expression](then_block, old_children, new_children)?)

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("if_true", if_true.get_json()))
    props.push(("then_block", then_block.get_json()))
