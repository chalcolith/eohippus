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

class val TypeLambda is NodeData
  let bare: Bool
  let cap: (NodeWith[Keyword] | None)
  let identifier: (NodeWith[Identifier] | None)
  let type_params: (NodeWith[TypeParams] | None)
  let param_types: NodeSeqWith[TypeType]
  let return_type: (NodeWith[TypeType] | None)
  let partial: Bool
  let rcap: (NodeWith[Keyword] | None)
  let reph: (NodeWith[Token] | None)

  new val create(
    bare': Bool,
    cap': (NodeWith[Keyword] | None),
    identifier': (NodeWith[Identifier] | None),
    type_params': (NodeWith[TypeParams] | None),
    param_types': NodeSeqWith[TypeType],
    return_type': (NodeWith[TypeType] | None),
    partial': Bool,
    rcap': (NodeWith[Keyword] | None),
    reph': (NodeWith[Token] | None))
  =>
    bare = bare'
    cap = cap'
    identifier = identifier'
    type_params = type_params'
    param_types = param_types'
    return_type = return_type'
    partial = partial'
    rcap = rcap'
    reph = reph'

  fun name(): String => "TypeLambda"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("bare", bare.string()))
    props.push(("partial", partial.string()))
    match cap
    | let cap': Node =>
      props.push(("cap", cap'.get_json()))
    end
    match identifier
    | let identifier': Node =>
      props.push(("identifier", identifier'.get_json()))
    end
    match type_params
    | let type_params': Node =>
      props.push(("type_params", type_params'.get_json()))
    end
    if param_types.size() > 0 then
      props.push(("param_types", Nodes.get_json(param_types)))
    end
    match return_type
    | let return_type': Node =>
      props.push(("return_type", return_type'.get_json()))
    end
    match rcap
    | let rcap': Node =>
      props.push(("rcap", rcap'.get_json()))
    end
    match reph
    | let reph': Node =>
      props.push(("reph", reph'.get_json()))
    end
