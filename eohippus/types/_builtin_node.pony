use "collections/persistent"

use ast = "../ast"
use json = "../json"
use parser = "../parser"

class val _BuiltinNode is ast.NodeData
  let _name: String

  new create(name': String) =>
    _name = name'

  fun name(): String => "_Builtin_" + _name

  fun add_json_props(props: Array[(String, json.Item)]) =>
    None
