use json = "../../../../json"

use ".."

interface val TextDocumentRegistrationOptions is SendData
  fun val documentSelector(): (DocumentSelector | None)

  fun val get_json(): json.Item =>
    let props = Array[(String, json.Item)]
    match documentSelector()
    | let ds: DocumentSelector =>
      let seq =
        recover val
          json.Sequence.from_iter[DocumentFilter](
            ds.values(), {(filter) => filter.get_json() })
        end
      props.push(("documentSelector", seq))
    end
    json.Object(consume props)
