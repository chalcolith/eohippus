use json = "../../../../json"

use ".."

primitive TextDocumentSyncNone
primitive TextDocumentSyncFull
primitive TextDocumentSyncIncremental

type TextDocumentSyncKind is
  (TextDocumentSyncNone | TextDocumentSyncFull | TextDocumentSyncIncremental)

primitive TextDocumentSyncKindJson
  fun apply(tdsk: (TextDocumentSyncKind | None)): json.Item =>
    match tdsk
    | TextDocumentSyncNone =>
      I128(0)
    | TextDocumentSyncFull =>
      I128(1)
    | TextDocumentSyncIncremental =>
      I128(2)
    | None =>
      json.Null
    end

interface val TextDocumentSyncOptions is ResultData
  fun val openClose(): (Bool | None) => None
  fun val change(): (TextDocumentSyncKind | None) => None

  fun val get_json(): json.Item =>
    let props = Array[(String, json.Item)]
    match openClose()
    | let oc: Bool =>
      props.push(("openClose", oc))
    end
    match change()
    | let tdsk: TextDocumentSyncKind =>
      props.push(("change", TextDocumentSyncKindJson(tdsk)))
    end
    if props.size() > 0 then
      json.Object(props)
    else
      json.Null
    end
