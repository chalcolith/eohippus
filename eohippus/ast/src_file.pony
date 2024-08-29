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

  fun val clone(updates: ChildUpdateMap): NodeData =>
    SrcFile(
      locator,
      _map[Using](usings, updates),
      _map[Typedef](type_defs, updates))

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
    props.push(("locator", locator))
    if usings.size() > 0 then
      props.push(("usings", node.child_refs(usings)))
    end
    if type_defs.size() > 0 then
      props.push(("type_defs", node.child_refs(type_defs)))
    end

primitive ParseSrcFile
  fun apply(obj: json.Object, children: NodeSeq): (SrcFile | String) =>
    let locator =
      match try obj("locator")? end
      | let str: String box =>
        str
      else
        return "SrcFile.locator must be a string"
      end
    let usings =
      match ParseNode._get_seq_with[Using](
        obj,
        children,
        "usings",
        "SrcFile.usings must be a sequence of Using",
        false)
      | let seq: NodeSeqWith[Using] =>
        seq
      | let err: String =>
        return err
      end
    let type_defs =
      match ParseNode._get_seq_with[Typedef](
        obj,
        children,
        "type_defs",
        "SrcFile.type_defs must be a sequence of Typedef",
        false)
      | let seq: NodeSeqWith[Typedef] =>
        seq
      | let err: String =>
        return err
      end
    SrcFile(locator.clone(), usings, type_defs)
