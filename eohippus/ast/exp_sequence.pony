use "itertools"

use json = "../json"

class val ExpSequence is NodeData
  """A sequence of expressions, possibly separated by semicolons."""

  let expressions: NodeSeqWith[Expression]

  new val create(expressions': NodeSeqWith[Expression]) =>
    expressions = expressions'

  fun name(): String => "ExpSequence"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    ExpSequence(_map[Expression](expressions, updates))

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    props.push(("expressions", node.child_refs(expressions)))

primitive ParseExpSequence
  fun apply(obj: json.Object val, children: NodeSeq): (ExpSequence | String) =>
    let expressions =
      match ParseNode._get_seq_with[Expression](
        obj,
        children,
        "expressions",
        "ExpSequence.expressions must be a sequence of Expressions")
      | let seq: NodeSeqWith[Expression] =>
        seq
      | let err: String =>
        return err
      end
    ExpSequence(expressions)
