use "collections/persistent"

use ast = "../ast"
use json = "../json"
use parser = "../parser"

class val _BuiltinNode is ast.NodeData
  let _name: String

  new create(name': String) =>
    _name = name'

  fun name(): String => "_Builtin_" + _name

  fun val clone(old_children: ast.NodeSeq, new_children: ast.NodeSeq)
    : ast.NodeData
  =>
    this

  fun add_json_props(
    props: Array[(String, json.Item)],
    lines_and_columns: (ast.LineColumnMap | None) = None)
  =>
    None
