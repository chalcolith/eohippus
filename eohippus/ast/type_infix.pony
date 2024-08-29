use json = "../json"

class val TypeInfix is NodeData
  """
    An algebraic type expression.
    - `op`: `&` or `|`.
  """

  let types: NodeSeqWith[TypeType]
  let op: (NodeWith[Token] | None)

  new val create(
    types': NodeSeqWith[TypeType],
    op': (NodeWith[Token] | None))
  =>
    types = types'
    op = op'

  fun name(): String => "TypeInfix"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    TypeInfix(_map[TypeType](types, updates), _map_or_none[Token](op, updates))

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    match op
    | let op': NodeWith[Token] =>
      props.push(("op", node.child_ref(op')))
    end
    if types.size() > 0 then
      props.push(("types", node.child_refs(types)))
    end

primitive ParseTypeInfix
  fun apply(obj: json.Object, children: NodeSeq): (TypeInfix | String) =>
    let types =
      match ParseNode._get_seq_with[TypeType](
        obj,
        children,
        "types",
        "TypeInfix.types must be a sequence of TypeType",
        false)
      | let seq: NodeSeqWith[TypeType] =>
        seq
      | let err: String =>
        return err
      end
    let op =
      match ParseNode._get_child_with[Token](
        obj,
        children,
        "op",
        "TypeInfix.op must be a Token",
        false)
      | let node: NodeWith[Token] =>
        node
      | let err: String =>
        return err
      end
    TypeInfix(types, op)
