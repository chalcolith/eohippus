use rpc_data = "rpc/data"
use c_caps = "rpc/data/client_capabilities"

class ClientData
  var capabilities: (c_caps.ClientCapabilities | None) = None

  var workspaceFolders: (Array[rpc_data.WorkspaceFolder] val | None) = None
  var rootUri: (rpc_data.DocumentUri | None) = None
  var rootPath: (String | None) = None

  fun text_document_publish_diagnostics(): Bool =>
    match capabilities
    | let caps: c_caps.ClientCapabilities =>
      match caps.textDocument()
      | let td: c_caps.TextDocumentClientCapabilities =>
        match td.publishDiagnostics()
        | let pd: c_caps.PublishDiagnosticsClientCapabilities =>
          return true
        end
      end
    end
    false
