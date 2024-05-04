use json = "../../../../json"

use ".."

interface val NotebookDocumentSyncOptions is SendData
  fun val notebookSelector(): Array[NotebookSelectorData]
  fun val save(): (Bool | None) => None

  fun val get_json_props(): Array[(String, json.Item)] =>
    let selector_values = Array[json.Item]
    for selector in notebookSelector().values() do
      let sv = selector.get_json()
      if sv isnt json.Null then
        selector_values.push(sv)
      end
    end

    let props =
      [ as (String, json.Item):
        ("notebookSelector", json.Sequence(selector_values)) ]
    match save()
    | let s: Bool =>
      props.push(("save", s))
    end
    props

  fun val get_json(): json.Item =>
    json.Object(get_json_props())

interface val NotebookSelectorData is SendData
  fun val notebook(): (String | NotebookDocumentFilter | None) => None
  fun val cells(): (Array[NotebookCell] | None) => None

  fun val get_json(): json.Item =>
    let cells_value =
      match cells()
      | let arr: Array[NotebookCell] =>
        let cell_items = Array[json.Item]
        for cell in arr.values() do
          cell_items.push(cell.get_json())
        end
        json.Sequence(cell_items)
      end

    let props = Array[(String, json.Item)]
    match notebook()
    | let nb: String =>
      props.push(("notebook", nb))
    | let ndf: NotebookDocumentFilter =>
      props.push(("notebook", ndf.get_json()))
    end
    match cells_value
    | let cv: json.Sequence =>
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
