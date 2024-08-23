use json = "../../../../json"

interface val ClientCapabilities
  fun val workspace(): (WorkspaceClientCapabilities | None)
  fun val textDocument(): (TextDocumentClientCapabilities | None)
  fun val general(): (GeneralClientCapabilities | None)
  fun val experimental(): (json.Item val | None)

primitive ParseClientCapabilities
  fun apply(obj: json.Object val): (ClientCapabilities | String) =>
    let workspace' =
      try
        match obj("workspace")?
        | let ws_obj: json.Object val =>
          match ParseWorkspaceClientCapabilities(ws_obj)
          | let ws: WorkspaceClientCapabilities =>
            ws
          | let err: String =>
            return err
          end
        else
          return "clientCapabilities.workspace must be a JSON object"
        end
      end
    let textDocument' =
      try
        match obj("textDocument")?
        | let td_obj: json.Object val =>
          match ParseTextDocumentClientCapabilities(td_obj)
          | let td: TextDocumentClientCapabilities =>
            td
          | let err: String =>
            return err
          end
        else
          return "clientCapabilities.textDocument must be a JSON object"
        end
      end
    let general' =
      try
        match obj("general")?
        | let g_obj: json.Object val =>
          match ParseGeneralClientCapabilities(g_obj)
          | let g: GeneralClientCapabilities =>
            g
          | let err: String =>
            return err
          end
        else
          return "clientCapabilities.general must be a JSON object"
        end
      end
    let experimental' = try json.Clone(obj("experimental")?) end
    object val is ClientCapabilities
      fun val workspace(): (WorkspaceClientCapabilities | None) => workspace'
      fun val textDocument(): (TextDocumentClientCapabilities | None) =>
        textDocument'
      fun val general(): (GeneralClientCapabilities | None) => general'
      fun val experimental(): (json.Item val | None) => experimental'
    end
