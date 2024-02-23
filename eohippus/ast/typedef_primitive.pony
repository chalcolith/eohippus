use json = "../json"

class val TypedefPrimitive is NodeData
  """A primitive type declaration."""

  let identifier: NodeWith[Identifier]

  new val create(identifier': NodeWith[Identifier]) =>
    identifier = identifier'

  fun name(): String => "TypedefPrimitive"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    TypedefPrimitive(
      NodeChild.child_with[Identifier](identifier, old_children, new_children)?)

  fun add_json_props(
    props: Array[(String, json.Item)],
    lines_and_columns: (LineColumnMap | None) = None)
  =>
    props.push(("identifier", identifier.get_json(lines_and_columns)))
