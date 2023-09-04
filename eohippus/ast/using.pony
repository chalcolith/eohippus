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

  fun add_json_props(props: Array[(String, json.Item)]) =>
    match identifier
    | let identifier': NodeWith[Identifier] =>
      props.push(("identifier", identifier'.get_json()))
    end
    props.push(("path", path.get_json()))
    match define
    | let define': NodeWith[Identifier] =>
      props.push(("def_true", def_true.string()))
      props.push(("define", define'.get_json()))
    end

class val UsingFFI is NodeData
  new val create() =>
    None

  fun name(): String => "UsingFFI"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    None
