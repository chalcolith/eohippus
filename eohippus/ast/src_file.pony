use json = "../json"
use parser = "../parser"

class val SrcFile is NodeData
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

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ? =>
    SrcFile(
      locator,
      _child_seq_with[Using](usings, old_children, new_children)?,
      _child_seq_with[Typedef](type_defs, old_children, new_children)?)

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("locator", locator))
    if usings.size() > 0 then
      props.push(("usings", Nodes.get_json(usings)))
    end
    if type_defs.size() > 0 then
      props.push(("type_defs", Nodes.get_json(type_defs)))
    end
