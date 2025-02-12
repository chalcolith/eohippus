use "itertools"

use json = "../../../../json"
use ".."

interface val NotebookDocumentSyncOptions is SendData
  fun val notebookSelector(): Array[NotebookSelectorData]
  fun val save(): (Bool | None) => None

  fun val get_json_props(): Array[(String, json.Item)] =>
    let seq =
      json.Sequence(
        Iter[NotebookSelectorData](notebookSelector().values())
          .filter_map[json.Item](
            { (selector) =>
              let sj = selector.get_json()
              if sj isnt json.Null then
                sj
              else
                None
              end
            })
          .collect(Array[json.Item]))
    let props = [ as (String, json.Item): ("notebookSelector", seq) ]
    match save()
    | let s: Bool =>
      props.push(("save", s))
    end
    props

  fun val get_json(): json.Item =>
    json.Object(get_json_props())

interface val NotebookSelectorData is SendData
  fun val notebook(): (String | NotebookDocumentFilter | None) => None
  fun val cells(): (Array[NotebookCell] val | None) => None

  fun val get_json(): json.Item =>
    let cells_value =
      match cells()
      | let arr: Array[NotebookCell] val =>
        recover val
          json.Sequence.from_iter[NotebookCell](
            arr.values(), {(cell) => cell.get_json() })
        end
      end

    let props = Array[(String, json.Item)]
    match notebook()
    | let nb: String =>
      props.push(("notebook", nb))
    | let ndf: NotebookDocumentFilter =>
      props.push(("notebook", ndf.get_json()))
    end
    match cells_value
    | let cv: json.Sequence val =>
      props.push(("cells", cv))
    end
    if props.size() > 0 then
      json.Object(props)
    else
      json.Null
    end

interface val NotebookDocumentFilter is SendData
  fun val notebookType(): (String | None) => None
  fun val scheme(): (String | None) => None
  fun val pattern(): (String | None) => None

  fun val get_json(): json.Item =>
    let props = Array[(String, json.Item)]
    match notebookType()
    | let nt: String =>
      props.push(("notebookType", nt))
    end
    match scheme()
    | let s: String =>
      props.push(("scheme", s))
    end
    match pattern()
    | let p: String =>
      props.push(("pattern", p))
    end
    if props.size() > 0 then
      json.Object(props)
    else
      json.Null
    end

interface val NotebookCell is SendData
  fun val language(): String

  fun val get_json(): json.Item =>
    json.Object([ as (String, json.Item): ("language", language()) ])

interface val NotebookDocumentSyncRegistrationOptions is
  (NotebookDocumentSyncOptions & StaticRegistrationOptions)

  fun val get_json(): json.Item =>
    let props = get_json_props()
    match id()
    | let s: String =>
      props.push(("id", s))
    end
    json.Object(props)
