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

  fun val clone(updates: ChildUpdateMap): NodeData =>
    this

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("message", message))

primitive ParseErrorSection
  fun apply(obj: json.Object, children: NodeSeq): (ErrorSection | String) =>
    let message =
      match try obj("message")? end
      | let message': String box =>
        message'
      else
        return "ErrorSection.message must be a string"
      end
    ErrorSection(message.clone())
