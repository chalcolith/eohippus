use json = "../json"
use parser = "../parser"

class val SrcFile is NodeData
  let locator: parser.Locator
  let usings: NodeSeqWith[Using]
  let type_defs: NodeSeqWith[TypeDef]

  new create(
    locator': parser.Locator,
    usings': NodeSeqWith[Using],
    type_defs': NodeSeqWith[TypeDef])
  =>
    locator = locator'
    usings = usings'
    type_defs = type_defs'

  fun name(): String => "SrcFile"

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("locator", locator))
    if usings.size() > 0 then
      props.push(("usings", Nodes.get_json(usings)))
    end
    if type_defs.size() > 0 then
      props.push(("type_defs", Nodes.get_json(type_defs)))
    end
