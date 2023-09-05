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
  let body: Node

  new val create(body': Node) =>
    body = body'

  fun name(): String => "TypeAtom"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("body", body.get_json()))

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
