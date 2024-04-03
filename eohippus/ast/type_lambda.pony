use "itertools"

use json = "../json"

class val TypeLambda is NodeData
  """The type of a lambda function."""

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

  fun val clone(updates: ChildUpdateMap): NodeData =>
    TypeLambda(
      bare,
      _map_or_none[Keyword](cap, updates),
      _map_or_none[Identifier](identifier, updates),
      _map_or_none[TypeParams](type_params, updates),
      _map[TypeType](param_types, updates),
      _map_or_none[TypeType](return_type, updates),
      partial,
      _map_or_none[Keyword](rcap, updates),
      _map_or_none[Token](reph, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("bare", bare))
    props.push(("partial", partial))
    match cap
    | let cap': Node =>
      props.push(("cap", node.child_ref(cap')))
    end
    match identifier
    | let identifier': Node =>
      props.push(("identifier", node.child_ref(identifier')))
    end
    match type_params
    | let type_params': Node =>
      props.push(("type_params", node.child_ref(type_params')))
    end
    if param_types.size() > 0 then
      props.push(("param_types", node.child_refs(param_types)))
    end
    match return_type
    | let return_type': Node =>
      props.push(("return_type", node.child_ref(return_type')))
    end
    match rcap
    | let rcap': Node =>
      props.push(("rcap", node.child_ref(rcap')))
    end
    match reph
    | let reph': Node =>
      props.push(("reph", node.child_ref(reph')))
    end
