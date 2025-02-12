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

  fun val clone(updates: ChildUpdateMap): NodeData =>
    ExpIf(
      kind,
      _map[IfCondition](conditions, updates),
      _map_or_none[Expression](else_block, updates))

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
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

primitive ParseExpIf
  fun apply(obj: json.Object val, children: NodeSeq): (ExpIf | String) =>
    let kind =
      match try obj("kind")? end
      | let str: String box =>
        match str
        | "IfExp" =>
          IfExp
        | "IfDef" =>
          IfDef
        | "IfType" =>
          IfType
        else
          return "ExpIf.kind must be one of (IfExp | IfDef | IfType)"
        end
      else
        return "ExpIf.kind must be a string"
      end
    let conditions =
      match ParseNode._get_seq_with[IfCondition](
        obj,
        children,
        "conditions",
        "ExpIf.conditions must be a sequence of IfCondition")
      | let seq: NodeSeqWith[IfCondition] =>
        seq
      | let err: String =>
        return err
      end
    let else_block =
      match ParseNode._get_child_with[Expression](
        obj,
        children,
        "else_block",
        "ExpIf.else_block must be an Expression",
        false)
      | let node: NodeWith[Expression] =>
        node
      | let err: String =>
        return err
      end
    ExpIf(kind, conditions, else_block)

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

  fun val clone(updates: ChildUpdateMap): NodeData =>
    IfCondition(
      _map_with[Expression](if_true, updates),
      _map_with[Expression](then_block, updates))

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    props.push(("if_true", node.child_ref(if_true)))
    props.push(("then_block", node.child_ref(then_block)))

primitive ParseIfCondition
  fun apply(obj: json.Object val, children: NodeSeq): (IfCondition | String) =>
    let if_true =
      match ParseNode._get_child_with[Expression](
        obj,
        children,
        "if_true",
        "IfCondition.if_true must be an Expression")
      | let node: NodeWith[Expression] =>
        node
      | let err: String =>
        return err
      else
        return "IfCondition.if_true must be an Expression"
      end
    let then_block =
      match ParseNode._get_child_with[Expression](
        obj,
        children,
        "then_block",
        "IfCondition.then_block must be an Expression")
      | let node: NodeWith[Expression] =>
        node
      | let err: String =>
        return err
      else
        return "IfCondition.then_block must be an Expression"
      end
    IfCondition(if_true, then_block)
