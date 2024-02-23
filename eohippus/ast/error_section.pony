use json = "../json"

class val ErrorSection is NodeData
  """
    Error sections are used to represent spans in the code where parsing has
    failed for some reason.  There is limited support for resuming parsing
    after an error section.
  """

  let message: String

  new val create(message': String) =>
    message = message'

  fun name(): String => "ErrorSection"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData =>
    this

  fun add_json_props(
    props: Array[(String, json.Item)],
    lines_and_columns: (LineColumnMap | None) = None)
  =>
    props.push(("message", message))
