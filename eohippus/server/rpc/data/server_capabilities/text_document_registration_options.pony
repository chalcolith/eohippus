use json = "../../../../json"

use ".."

interface val TextDocumentRegistrationOptions is SendData
  fun val documentSelector(): (DocumentSelector | None)

  fun val get_json(): json.Item =>
    let props = Array[(String, json.Item)]
    match documentSelector()
    | let ds: DocumentSelector =>
      let items = Array[json.Item]
      for filter in ds.values() do
        items.push(filter.get_json())
      end
      props.push(("documentSelector", json.Sequence(items)))
    end
    json.Object(props)
