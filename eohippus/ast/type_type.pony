use "itertools"

use json = "../json"

type TypeType is
  (TypeArrow | TypeAtom | TypeTuple | TypeInfix | TypeNominal | TypeLambda)

class val TypeArrow is NodeData
  let lhs: Node
  let rhs: (NodeWith[TypeType] | None)

  new val create(lhs': Node, rhs': (NodeWith[TypeType] | None)) =>
    lhs = lhs'
    rhs = rhs'

  fun name(): String => "TypeArrow"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("lhs", lhs.get_json()))
    match rhs
    | let rhs': NodeWith[TypeType] =>
      props.push(("rhs", rhs'.get_json()))
    end

class val TypeAtom is NodeData
  let child: Node

  new val create(child': Node) =>
    child = child'

  fun name(): String => "TypeAtom"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("child", child.get_json()))

class val TypeTuple is NodeData
  let types: NodeSeqWith[TypeType]

  new val create(types': NodeSeqWith[TypeType]) =>
    types = types'

  fun name(): String => "TypeTuple"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("types", Nodes.get_json(types)))

class val TypeInfix is NodeData
  let types: NodeSeqWith[TypeType]
  let op: (NodeWith[Token] | None)

  new val create(
    types': NodeSeqWith[TypeType],
    op': (NodeWith[Token] | None))
  =>
    types = types'
    op = op'

  fun name(): String => "TypeInfix"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    match op
    | let op': NodeWith[Token] =>
      props.push(("op", op'.get_json()))
    end
    if types.size() > 0 then
      props.push(("types", Nodes.get_json(types)))
    end

class val TypeNominal is NodeData
  let lhs: NodeWith[Identifier]
  let rhs: (NodeWith[Identifier] | None)
  let params: (NodeWith[TypeParams] | None)
  let cap: (NodeWith[Keyword] | None)
  let eph: (NodeWith[Token] | None)

  new val create(
    lhs': NodeWith[Identifier],
    rhs': (NodeWith[Identifier] | None),
    params': (NodeWith[TypeParams] | None),
    cap': (NodeWith[Keyword] | None),
    eph': (NodeWith[Token] | None))
  =>
    lhs = lhs'
    rhs = rhs'
    params = params'
    cap = cap'
    eph = eph'

  fun name(): String => "TypeNominal"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("lhs", lhs.get_json()))
    match rhs
    | let rhs': NodeWith[Identifier] =>
      props.push(("rhs", rhs'.get_json()))
    end
    match params
    | let params': NodeWith[TypeParams] =>
      if params'.data().params.size() > 0 then
        props.push(("params", params'.get_json()))
      end
    end
    match cap
    | let cap': NodeWith[Keyword] =>
      props.push(("cap", cap'.get_json()))
    end
    match eph
    | let eph': NodeWith[Token] =>
      props.push(("eph", eph'.get_json()))
    end
