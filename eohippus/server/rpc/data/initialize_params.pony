use json = "../../../json"

use c_caps = "client_capabilities"

trait val InitializeParams is WorkDoneProgressParams
  fun val processId(): (I128 | None)
  fun val clientInfo(): (ClientInfo | None)
  fun val locale(): (String | None)
  fun val rootPath(): (String | None)
  fun val rootUri(): (DocumentUri | None)
  fun val initializationOptions(): (json.Item | None)
  fun val capabilities(): c_caps.ClientCapabilities
  fun val trace(): (TraceValue | None)
  fun val workspaceFolders(): (Array[WorkspaceFolder] val | None)

primitive ParseInitializeParams
  fun apply(obj: json.Object val): (InitializeParams | String) =>
    let workDoneToken': (I128 | String | None) =
      try
        match obj("workDoneToken")?
        | let int: I128 =>
          int
        | let str: String =>
          str.clone()
        else
          return
            "initializeParams.workDoneToken must be of type (integer | string)"
        end
      end
    let processId' =
      try
        match obj("processId")?
        | let id: I128 =>
          id
        | json.Null =>
          None
        else
          return "initializeParams.processId must be of type (integer | null)"
        end
      else
        return "initializeParams must contain 'processId'"
      end
    let clientInfo' =
      try
        match obj("clientInfo")?
        | let ci_obj: json.Object val =>
          match ParseClientInfo(ci_obj)
          | let ci: ClientInfo => ci
          | let err: String => return err
          end
        else
          return "initializeParams.clientInfo must be a JSON object"
        end
      end
    let locale': (String | None) =
      try
        match obj("locale")?
        | let str: String =>
          str.clone()
        else
          return "initializeParams.locale must be of type string"
        end
      end
    let rootPath': (String | None) =
      try
        match obj("rootPath")?
        | let str: String =>
          str.clone()
        | json.Null =>
          None
        else
          return "initializeParams.rootPath must be of type (string | null)"
        end
      end
    let rootUri': (String | None) =
      try
        match obj("rootUri")?
        | let str: String =>
          str.clone()
        | json.Null =>
          None
        else
          return "initializeParams.rootUri must be of type (string | null)"
        end
      else
        return "initializeParams must contain 'rootUri'"
      end
    let initializationOptions': (json.Item val | None) =
      try
        json.Clone(obj("initializationOptions")?)
      end
    let capabilities' =
      try
        match obj("capabilities")?
        | let cap_obj: json.Object val =>
          match c_caps.ParseClientCapabilities(cap_obj)
          | let client_caps: c_caps.ClientCapabilities =>
            client_caps
          | let err: String =>
            return err
          end
        else
          return "initializeParams.clientCapabilities must be a JSON object"
        end
      else
        return "initializeParams must contain 'clientCapabilities'"
      end
    let trace' =
      try
        match obj("trace")?
        | let str: String =>
          match ParseTraceValue(str)
          | let tv: TraceValue =>
            tv
          | let err: String =>
            return err
          end
        else
          return "initializationParams.trace must be of type string"
        end
      end
    let workspaceFolders': (Array[WorkspaceFolder] val | None) =
      try
        match obj("workspaceFolders")?
        | let wf_seq: json.Sequence val =>
          let folders: Array[WorkspaceFolder] trn = Array[WorkspaceFolder]
          for wf_item in wf_seq.values() do
            match wf_item
            | let wf_obj: json.Object val =>
              match ParseWorkspaceFolder(wf_obj)
              | let wf: WorkspaceFolder =>
                folders.push(wf)
              | let err: String =>
                return err
              end
            else
              return "workspaceFolders must be an array of objects"
            end
          end
          consume folders
        else
          return "workspaceFolders must be an array"
        end
      end
    object val is InitializeParams
      fun val workDoneToken(): (ProgressToken | None) => workDoneToken'
      fun val processId(): (I128 | None) => processId'
      fun val clientInfo(): (ClientInfo | None) => clientInfo'
      fun val locale(): (String | None) => locale'
      fun val rootPath(): (String | None) => rootPath'
      fun val rootUri(): (DocumentUri | None) => rootUri'
      fun val initializationOptions(): (json.Item val | None) =>
        initializationOptions'
      fun val capabilities(): c_caps.ClientCapabilities => capabilities'
      fun val trace(): (TraceValue | None) => trace'
      fun val workspaceFolders(): (Array[WorkspaceFolder] val | None) =>
        workspaceFolders'
    end

interface val WorkspaceFolder
  fun val uri(): Uri
  fun val name(): String

primitive ParseWorkspaceFolder
  fun apply(obj: json.Object val): (WorkspaceFolder | String) =>
    let uri': String =
      try
        match obj("uri")?
        | let s: String =>
          s.clone()
        else
          return "workspaceFolder.uri must be of type string"
        end
      else
        return "workspaceFolder must contain 'uri'"
      end
    let name': String =
      try
        match obj("name")?
        | let s: String =>
          s.clone()
        else
          return "workspaceFolder.name must be of type string"
        end
      else
        return "workspaceFolder must contain 'name'"
      end
    object val is WorkspaceFolder
      fun uri(): Uri => uri'
      fun name(): String => name'
    end

primitive TraceOff
primitive TraceMessages
primitive TraceVerbose

type TraceValue is (TraceOff | TraceMessages | TraceVerbose)

primitive ParseTraceValue
  fun apply(item: json.Item): (TraceValue | String) =>
    match item
    | "off" =>
      TraceOff
    | "messages" =>
      TraceMessages
    | "verbose" =>
      TraceVerbose
    else
      "traceValue must be one of ('off' | 'messages' | 'verbose')"
    end

interface val SetTraceParams
  fun val value(): TraceValue

primitive ParseSetTraceParams
  fun apply(obj: json.Object val): (SetTraceParams | String) =>
    let value' =
      match try obj("value")? end
      | let trace_value: String =>
        match ParseTraceValue(trace_value)
        | let tv: TraceValue =>
          tv
        | let err: String =>
          return err
        end
      else
        return "traceValue should be a string"
      end
    object val is SetTraceParams
      fun val value(): TraceValue => value'
    end
