use json = "../json"
use parser = "../parser"
use ".."

type Using is (UsingPony | UsingFFI)

class val UsingPony is NodeData
  """A `using` statement referencing a Pony package."""

  let identifier: (NodeWith[Identifier] | None)
  let path: NodeWith[LiteralString]
  let def_true: Bool
  let define: (NodeWith[Identifier] | None)

  new val create(
    identifier': (NodeWith[Identifier] | None),
    path': NodeWith[LiteralString],
    def_true': Bool,
    define': (NodeWith[Identifier] | None))
  =>
    identifier = identifier'
    path = path'
    def_true = def_true'
    define = define'

  fun name(): String => "UsingPony"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    UsingPony(
      _map_or_none[Identifier](identifier, updates),
      _map_with[LiteralString](path, updates),
      def_true,
      _map_or_none[Identifier](define, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    match identifier
    | let identifier': NodeWith[Identifier] =>
      props.push(("identifier", node.child_ref(identifier')))
    end
    props.push(("path", node.child_ref(path)))
    match define
    | let define': NodeWith[Identifier] =>
      if not def_true then
        props.push(("def_true", def_true))
      end
      props.push(("define", node.child_ref(define')))
    end

primitive ParseUsingPony
  fun apply(obj: json.Object, children: NodeSeq): (UsingPony | String) =>
    let identifier =
      match ParseNode._get_child_with[Identifier](
        obj,
        children,
        "identifier",
        "UsingPony.identifier must be an identifier",
        false)
      | let node: NodeWith[Identifier] =>
        node
      | let err: String =>
        return err
      end
    let path =
      match ParseNode._get_child_with[LiteralString](
        obj,
        children,
        "path",
        "UsingPony.path must be a LiteralString")
      | let node: NodeWith[LiteralString] =>
        node
      | let err: String =>
        return err
      else
        return "UsingPony.path must be a LiteralString"
      end
    let def_true =
      match try obj("def_true")? end
      | let bool: Bool =>
        bool
      | let _: json.Item =>
        return "UsingPony.def_true must be a boolean"
      else
        false
      end
    let define =
      match ParseNode._get_child_with[Identifier](
        obj,
        children,
        "define",
        "UsingPony.define must be an Identifier",
        false)
      | let node: NodeWith[Identifier] =>
        node
      | let err: String =>
        return err
      end
    UsingPony(identifier, path, def_true, define)

class val UsingFFI is NodeData
  """A `using` statement referencing an extern FFI function."""

  let identifier: (NodeWith[Identifier] | None)
  let fun_name: (NodeWith[Identifier] | NodeWith[LiteralString])
  let type_args: NodeWith[TypeArgs]
  let params: (NodeWith[MethodParams] | None)
  let partial: Bool
  let def_true: Bool
  let define: (NodeWith[Identifier] | None)

  new val create(
    identifier': (NodeWith[Identifier] | None),
    fun_name': (NodeWith[Identifier] | NodeWith[LiteralString]),
    type_args': NodeWith[TypeArgs],
    params': (NodeWith[MethodParams] | None),
    partial': Bool,
    def_true': Bool,
    define': (NodeWith[Identifier] | None))
  =>
    identifier = identifier'
    fun_name = fun_name'
    type_args = type_args'
    params = params'
    partial = partial'
    def_true = def_true'
    define = define'

  fun name(): String => "UsingFFI"

  fun val clone(updates: ChildUpdateMap): NodeData =>
    UsingFFI(
      _map_or_none[Identifier](identifier, updates),
      try
        updates(fun_name)? as (NodeWith[Identifier] | NodeWith[LiteralString])
      else
        fun_name
      end,
      _map_with[TypeArgs](type_args, updates),
      _map_or_none[MethodParams](params, updates),
      partial,
      def_true,
      _map_or_none[Identifier](define, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    match identifier
    | let identifier': NodeWith[Identifier] =>
      props.push(("identifier", node.child_ref(identifier')))
    end
    props.push(("fun_name", node.child_ref(fun_name)))
    props.push(("type_args", node.child_ref(type_args)))
    match params
    | let params': NodeWith[MethodParams] =>
      props.push(("params", node.child_ref(params')))
    end
    if partial then
      props.push(("partial", partial))
    end
    match define
    | let define': NodeWith[Identifier] =>
      if not def_true then
        props.push(("def_true", def_true))
      end
      props.push(("define", node.child_ref(define')))
    end

primitive ParseUsingFFI
  fun apply(obj: json.Object, children: NodeSeq): (UsingFFI | String) =>
    let identifier =
      match ParseNode._get_child_with[Identifier](
        obj,
        children,
        "identifier",
        "UsingFFI.identifier must be a string",
        false)
      | let node: NodeWith[Identifier] =>
        node
      | let err: String =>
        return err
      end
    let fun_name =
      match ParseNode._get_child(
        obj,
        children,
        "fun_name",
        "UsingFFI.fun_name must be an Identifier or LiteralString")
      | let id: NodeWith[Identifier] =>
        id
      | let ls: NodeWith[LiteralString] =>
        ls
      | let err: String =>
        return err
      else
        return "UsingFFI.fun_name must be an Identifier or LiteralString"
      end
    let type_args =
      match ParseNode._get_child_with[TypeArgs](
        obj,
        children,
        "type_args",
        "UsingFFI.type_args must be a TypeArgs")
      | let node: NodeWith[TypeArgs] =>
        node
      | let err: String =>
        return err
      else
        return "UsingFFI.type_args must be a TypeArgs"
      end
    let params =
      match ParseNode._get_child_with[MethodParams](
        obj,
        children,
        "params",
        "UsingFFI.params must be a MethodParams",
        false)
      | let node: NodeWith[MethodParams] =>
        node
      | let err: String =>
        return err
      end
    let partial =
      match try obj("partial")? end
      | let bool: Bool =>
        bool
      | let _: json.Item =>
        return "UsingFFI.partial must be a boolean"
      else
        false
      end
    let def_true =
      match try obj("def_true")? end
      | let bool: Bool =>
        bool
      | let _: json.Item =>
        return "UsingPony.def_true must be a boolean"
      else
        false
      end
    let define =
      match ParseNode._get_child_with[Identifier](
        obj,
        children,
        "define",
        "UsingPony.define must be an Identifier",
        false)
      | let node: NodeWith[Identifier] =>
        node
      | let err: String =>
        return err
      end
    UsingFFI(identifier, fun_name, type_args, params, partial, def_true, define)
