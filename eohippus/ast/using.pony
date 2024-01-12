use json = "../json"
use parser = "../parser"
use ".."

type Using is (UsingPony | UsingFFI)

class val UsingPony is NodeData
  let identifier: (NodeWith[Identifier] | None)
  let path: NodeWith[Literal]
  let def_true: Bool
  let define: (NodeWith[Identifier] | None)

  new val create(
    identifier': (NodeWith[Identifier] | None),
    path': NodeWith[Literal],
    def_true': Bool,
    define': (NodeWith[Identifier] | None))
  =>
    identifier = identifier'
    path = path'
    def_true = def_true'
    define = define'

  fun name(): String => "Using"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    UsingPony(
      NodeChild.with_or_none[Identifier](identifier, old_children, new_children)?,
      NodeChild.child_with[Literal](path, old_children, new_children)?,
      def_true,
      NodeChild.with_or_none[Identifier](define, old_children, new_children)?)

  fun add_json_props(props: Array[(String, json.Item)]) =>
    match identifier
    | let identifier': NodeWith[Identifier] =>
      props.push(("identifier", identifier'.get_json()))
    end
    props.push(("path", path.get_json()))
    match define
    | let define': NodeWith[Identifier] =>
      if not def_true then
        props.push(("def_true", def_true))
      end
      props.push(("define", define'.get_json()))
    end

class val UsingFFI is NodeData
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

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    UsingFFI(
      NodeChild.with_or_none[Identifier](identifier, old_children, new_children)?,
      NodeChild(fun_name, old_children, new_children)? as
        (NodeWith[Identifier] | NodeWith[LiteralString]),
      NodeChild.child_with[TypeArgs](type_args, old_children, new_children)?,
      NodeChild.with_or_none[MethodParams](params, old_children, new_children)?,
      partial,
      def_true,
      NodeChild.with_or_none[Identifier](define, old_children, new_children)?)

  fun add_json_props(props: Array[(String, json.Item)]) =>
    match identifier
    | let identifier': NodeWith[Identifier] =>
      props.push(("identifier", identifier'.get_json()))
    end
    props.push(("name", fun_name.get_json()))
    props.push(("type_args", type_args.get_json()))
    match params
    | let params': NodeWith[MethodParams] =>
      props.push(("params", params'.get_json()))
    end
    if partial then
      props.push(("partial", partial))
    end
    match define
    | let define': NodeWith[Identifier] =>
      if not def_true then
        props.push(("def_true", def_true))
      end
      props.push(("define", define'.get_json()))
    end
