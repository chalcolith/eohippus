use json = "../json"
use parser = "../parser"

class val SrcFile is NodeData
  """
    A Pony source file.
  """

  let locator: parser.Locator
  let usings: NodeSeqWith[Using]
  let type_defs: NodeSeqWith[Typedef]

  new val create(
    locator': parser.Locator,
    usings': NodeSeqWith[Using],
    type_defs': NodeSeqWith[Typedef])
  =>
    locator = locator'
    usings = usings'
    type_defs = type_defs'

  fun name(): String => "SrcFile"

  fun val clone(updates: ChildUpdateMap): SrcFile =>
    SrcFile(
      locator,
      _map[Using](usings, updates),
      _map[Typedef](type_defs, updates))

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    props.push(("locator", locator))
    if usings.size() > 0 then
      props.push(("usings", node.child_refs(usings)))
    end
    if type_defs.size() > 0 then
      props.push(("type_defs", node.child_refs(type_defs)))
    end
