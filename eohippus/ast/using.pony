use json = "../json"
use parser = "../parser"
use ".."

type Using is (UsingPony | UsingFFI)

class val UsingPony is NodeData
  """A `using` statement referencing a Pony package."""

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
