use json = "../json"

class val Identifier is NodeData
  let string: String

  new val create(string': String) =>
    string = string'

  fun name(): String => "Identifier"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData =>
    this

  fun add_json_props(
    props: Array[(String, json.Item)],
    lines_and_columns: (LineColumnMap | None) = None)
  =>
    props.push(("string", string))
