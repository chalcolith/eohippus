use "collections"
use "files"
use "logger"
use "time"

use analyzer = "../analyzer"
use ast = "../ast"
use handlers = "handlers"
use handle_text_document = "handlers/text_document"
use json = "../json"
use parser = "../parser"
use rpc = "rpc"
use rpc_data = "rpc/data"
use c_caps = "rpc/data/client_capabilities"
use ".."

primitive ServerNotConnected
primitive ServerNotInitialized
primitive ServerInitializing
primitive ServerInitialized
primitive ServerShuttingDown
primitive ServerExiting

type ServerState is
  ( ServerNotConnected
  | ServerNotInitialized
  | ServerInitializing
  | ServerInitialized
  | ServerShuttingDown
  | ServerExiting )

actor EohippusServer is Server
  let _env: Env
  let _log: Logger[String]
  let _config: ServerConfig

  var _notify: ServerNotify iso
  var _rpc_handler: rpc.Handler

  var _state: ServerState = ServerNotConnected
  var _trace_value: rpc_data.TraceValue = rpc_data.TraceMessages
  var _exit_code: I32 = 0

  let _parser_context: parser.Context
  let _parser_grammar: parser.NamedRule val

  let _client_data: ClientData

  let _workspaces: Workspaces
  let _src_files: SrcFiles

  let _handle_initialize: handlers.Initialize
  let _handle_shutdown: handlers.Shutdown

  let _handle_text_document_did_open: handle_text_document.DidOpen
  let _handle_text_document_did_change: handle_text_document.DidChange
  let _handle_text_document_did_close: handle_text_document.DidClose

  var _next_task_id: USize = 1

  new create(
    env: Env,
    log: Logger[String],
    config: ServerConfig,
    notify: (ServerNotify iso | None) = None,
    rpc_handler: (rpc.Handler | None) = None)
  =>
    _env = env
    _log = log
    _config = config
    _notify =
      match notify
      | let sn: ServerNotify iso =>
        consume sn
      else
        _DummyNotify
      end
    _rpc_handler =
      match rpc_handler
      | let rh: rpc.Handler =>
        rh
      else
        rpc.DummyHandler(_log)
      end

    _parser_context = parser.Context([])
    _parser_grammar = parser.Builder(_parser_context).src_file.src_file

    _client_data = ClientData

    _workspaces = Workspaces(_log, this, _parser_grammar)
    _src_files = SrcFiles

    _handle_initialize = handlers.Initialize(_log, this)
    _handle_shutdown = handlers.Shutdown(_log, this)
    _handle_text_document_did_open = handle_text_document.DidOpen(
      _log, this, _config)
    _handle_text_document_did_change = handle_text_document.DidChange(
      _log, _config)
    _handle_text_document_did_close = handle_text_document.DidClose(
      _log, _config)

  fun ref _get_next_task_id(): USize =>
    let id = _next_task_id
    _next_task_id = _next_task_id + 1
    id

  fun _get_canonical_path(client_uri: String): FilePath =>
    var path_name = StringUtil.url_decode(
      if client_uri.compare_sub("file://", 7) == Equal then
        client_uri.trim(7)
      else
        client_uri
      end)
    ifdef windows then
      try
        if path_name(0)? == '/' then
          path_name = path_name.trim(1)
        end
      end
    end

    var file_path = FilePath(FileAuth(_env.root), path_name)
    try
      file_path = file_path.canonical()?
    end
    file_path

  be set_notify(notify: ServerNotify iso) =>
    _log(Fine) and _log.log("server notify set")
    _notify = consume notify

  be notify_listening() =>
    let self: Server tag = this
    _notify.listening(self)

  be notify_connected() =>
    let self: Server tag = this
    _notify.connected(self)

  be notify_errored() =>
    let self: Server tag = this
    _notify.errored(self)

  be notify_initializing() =>
    let self: Server tag = this
    _notify.initializing(self)

  be notify_initialized() =>
    let self: Server tag = this
    _notify.initialized(self)

  be notify_received_request(id: (I128 | String | None), method: String) =>
    let self: Server tag = this
    _notify.received_request(self, id, method)

  be notify_received_notification(method: String) =>
    let self: Server tag = this
    _notify.received_notification(self, method)

  be notify_sent_error(
    id: (I128 | String | None), code: I128, message: String)
  =>
    let self: Server tag = this
    _notify.sent_error(self, id, code, message)

  be notify_disconnected() =>
    let self: Server tag = this
    _notify.disconnected(self)

  be notify_shutting_down() =>
    let self: Server tag = this
    _notify.shutting_down(self)

  be notify_exiting(code: I32) =>
    _notify.exiting(code)

  be set_rpc_handler(rpc_handler: rpc.Handler) =>
    _log(Info) and _log.log("server rpc handler set")
    _rpc_handler = rpc_handler

  be rpc_listening() =>
    _log(Info) and _log.log("server rpc handler listening")
    notify_listening()

  be rpc_connected() =>
    _log(Info) and _log.log("server rpc handler connected")
    _state = ServerNotInitialized
    notify_connected()

  be rpc_error() =>
    _log(Info) and _log.log("rpc handler error")
    _exit_code = 1
    notify_errored()
    exit()

  be rpc_closed() =>
    _log(Info) and _log.log("rpc handler closed")
    notify_disconnected()
    exit()

  be dispose() =>
    _log(Info) and _log.log("server disposed; closing rpc handler")
    _rpc_handler.close()

    for workspace in _workspaces.by_client_uri.values() do
      workspace.analyze.dispose()
    end
    _workspaces.by_client_uri.clear()
    _workspaces.by_canonical_path.clear()
    _workspaces.by_analyzer.clear()

  be exit() =>
    if _state isnt ServerExiting then
      _log(Info) and _log.log("server exiting with code " + _exit_code.string())
      // make sure things are cleaned up
      _state = ServerExiting
      _env.exitcode(_exit_code)
      notify_exiting(_exit_code)
    end

  fun ref _handle_request(status: ((ServerState | None), (I32 | None))) =>
    match status._1
    | let state: ServerState =>
      _state = state
    end
    match status._2
    | let exit_code: I32 =>
      _exit_code = exit_code
    end

  be request_initialize(
    message: rpc_data.RequestMessage,
    params: rpc_data.InitializeParams)
  =>
    _handle_request(_handle_initialize(_state, _rpc_handler, message, params))

  be request_shutdown(message: rpc_data.RequestMessage) =>
    _handle_request(_handle_shutdown(_state, _rpc_handler, message))

  be notification_initialized() =>
    _log(Fine) and _log.log("notification: initialized")
    notify_received_notification("initialized")
    if _state is ServerInitializing then
      _state = ServerInitialized
      notify_initialized()

      match _client_data.workspaceFolders
      | let folders: Array[rpc_data.WorkspaceFolder] val =>
        for folder in folders.values() do
          open_workspace(folder.name(), folder.uri())
        end
      else
        match _client_data.rootUri
        | let uri: rpc_data.DocumentUri =>
          open_workspace(uri, uri)
        else
          match _client_data.rootPath
          | let path: String =>
            open_workspace(path, path)
          end
        end
      end
    else
      _log(Error) and _log.log("initialized notification when not initializing")
    end

  be notification_set_trace(params: rpc_data.SetTraceParams) =>
    _log(Fine) and _log.log("trace value set")
    _trace_value = params.value()

  be notification_did_open_text_document(
    params: rpc_data.DidOpenTextDocumentParams)
  =>
    _handle_request(_handle_text_document_did_open(
      FileAuth(_env.root),
      _workspaces,
      _src_files,
      _get_next_task_id(),
      params))

  be notification_did_change_text_document(
    params: rpc_data.DidChangeTextDocumentParams)
  =>
    _handle_request(_handle_text_document_did_change(
      FileAuth(_env.root),
      _workspaces,
      _src_files,
      _get_next_task_id(),
      params))

  be notification_did_close_text_document(
    params: rpc_data.DidCloseTextDocumentParams)
  =>
    _handle_request(_handle_text_document_did_close(
      FileAuth(_env.root),
      _workspaces,
      _src_files,
      _get_next_task_id(),
      params))

  be notification_exit() =>
    _log(Fine) and _log.log("notification: exit")
    notify_received_notification("exit")
    var close_handler = false
    match _state
    | ServerNotInitialized =>
      _log(Warn) and _log.log("  ungraceful exit requested before initialize")
      _state = ServerExiting
      _exit_code = 1
      close_handler = true
    | ServerInitializing =>
      _log(Warn) and _log.log("  ungraceful exit requested while initializing")
      _state = ServerExiting
      _exit_code = 1
      close_handler = true
    | ServerInitialized =>
      _log(Warn) and _log.log("  ungraceful exit requested before shutdown")
      _state = ServerExiting
      _exit_code = 1
      close_handler = true
    | ServerShuttingDown =>
      _state = ServerExiting
      _exit_code = 0
      close_handler = true
    end

    if close_handler then
      notify_exiting(_exit_code)
      _rpc_handler.close()
    end

  be set_client_data(
    capabilities: c_caps.ClientCapabilities,
    workspaceFolders: (Array[rpc_data.WorkspaceFolder] val | None),
    rootUri: (rpc_data.DocumentUri | None),
    rootPath: (String | None))
  =>
    _client_data.capabilities = capabilities
    _client_data.workspaceFolders = workspaceFolders
    _client_data.rootUri = rootUri
    _client_data.rootPath = rootPath

  be open_workspace(name: String, client_uri: String) =>
    _log(Fine) and _log.log("open workspace " + name + " " + client_uri)
    if not _workspaces.by_client_uri.contains(client_uri) then
      let canonical_path = _get_canonical_path(client_uri)
      let ponyc_executable =
        match _config.ponyc_executable
        | let str: String =>
          FilePath(FileAuth(_env.root), str)
        end
      let analyze = analyzer.EohippusAnalyzer(
        _log, FileAuth(_env.root), _parser_grammar
        where
          workspace = canonical_path,
          storage_path = None,
          pony_path = [],
          ponyc_executable = ponyc_executable,
          pony_packages_path = None,
          notify = this)
      let workspace = WorkspaceInfo(
        name, client_uri, canonical_path.path, analyze)
      _workspaces.by_client_uri.update(client_uri, workspace)
      _workspaces.by_canonical_path.update(canonical_path.path, workspace)
      _workspaces.by_analyzer.update(analyze, workspace)
    else
      _log(Warn) and _log.log("workspace " + client_uri + " already open")
    end

  fun _clear_errors(
    canonical_path: String,
    dest: Map[String, Array[analyzer.AnalyzerError]])
  =>
    try
      dest(canonical_path)?.clear()
    end

  fun _add_errors(
    src: ReadSeq[analyzer.AnalyzerError],
    dest: Map[String, Array[analyzer.AnalyzerError]])
  =>
    for err in src.values() do
      let arr =
        try
          dest(err.canonical_path)?
        else
          let arr' = Array[analyzer.AnalyzerError]
          dest(err.canonical_path) = arr'
          arr'
        end
      arr.push(err)
    end

  fun _get_range(err: analyzer.AnalyzerError): rpc_data.Range =>
    object val is rpc_data.Range
      let _err: analyzer.AnalyzerError = err
      fun val start(): rpc_data.Position =>
        object val is rpc_data.Position
          fun val line(): I128 => I128.from[USize](_err.line)
          fun val character(): I128 => I128.from[USize](_err.column)
        end
      fun val endd(): rpc_data.Position =>
        object val is rpc_data.Position
          fun val line(): I128 => I128.from[USize](_err.next_line)
          fun val character(): I128 => I128.from[USize](_err.next_column)
        end
    end

  fun _notify_file_diagnostics(
    canonical_path: String,
    errors: Array[analyzer.AnalyzerError])
  =>
    let path: String iso = canonical_path.clone() .> replace("\\", "/")
    let client_uri: String val =
      "file:///" + StringUtil.url_encode(consume path)
    let diagnostics: Array[rpc_data.Diagnostic] trn = []
    for err in errors.values() do
      let range' = _get_range(err)
      let severity' =
        match err.severity
        | analyzer.AnalyzeError =>
          rpc_data.DiagnosticError
        | analyzer.AnalyzeWarning =>
          rpc_data.DiagnosticWarning
        | analyzer.AnalyzeInfo =>
          rpc_data.DiagnosticInformation
        | analyzer.AnalyzeHint =>
          rpc_data.DiagnosticHint
        end
      let message' = err.message
      diagnostics.push(
        object val is rpc_data.Diagnostic
          fun val range(): rpc_data.Range => range'
          fun val severity(): rpc_data.DiagnosticSeverity => severity'
          fun val message(): String => message'
        end)
    end
    let diagnostics': Array[rpc_data.Diagnostic] val =
      consume diagnostics
    let params =
      object val is rpc_data.PublishDiagnosticsParams
        fun val uri(): String => client_uri
        fun val diagnostics(): Array[rpc_data.Diagnostic] val =>
          diagnostics'
      end
    _log(Fine) and _log.log("textDocument/publishDiagnostics: " + client_uri +
      ": " + diagnostics'.size().string() + " diagnostics")
    _rpc_handler.notify("textDocument/publishDiagnostics", params)

  fun _notify_workspace_diagnostics(
    errors: Map[String, Array[analyzer.AnalyzerError]])
  =>
    var num_sent: USize = 0
    for canonical_path in errors.keys() do
      try
        _notify_file_diagnostics(canonical_path, errors(canonical_path)?)
      end
      num_sent = num_sent + 1
    end
    _log(Fine) and _log.log(
      "textDocument/publishDiagnostics: sent " + num_sent.string())

  be analyzed_workspace(
    analyze: analyzer.Analyzer,
    task_id: USize,
    workspace_errors: ReadSeq[analyzer.AnalyzerError] val,
    parse_errors: ReadSeq[analyzer.AnalyzerError] val,
    lint_errors: ReadSeq[analyzer.AnalyzerError] val,
    analyze_errors: ReadSeq[analyzer.AnalyzerError] val)
  =>
    _log(Fine) and _log.log(task_id.string() + ": workspace analyzed")

    match try _workspaces.by_analyzer(analyze)? end
    | let workspace: WorkspaceInfo =>
      workspace.errors.clear()
      _add_errors(workspace_errors, workspace.errors)
      _add_errors(parse_errors, workspace.errors)
      _add_errors(lint_errors, workspace.errors)
      _add_errors(analyze_errors, workspace.errors)

      if _client_data.text_document_publish_diagnostics() then
        _log(Fine) and _log.log(task_id.string() + ": sending diagnostics")
        _notify_workspace_diagnostics(workspace.errors)
      end
    end

  be analyzed_file(
    analyze: analyzer.Analyzer,
    task_id: USize,
    canonical_path: String,
    syntax_tree: (ast.SyntaxTree val | None),
    file_scope: (analyzer.SrcFileScope | None),
    parse_errors: ReadSeq[analyzer.AnalyzerError] val,
    lint_errors: ReadSeq[analyzer.AnalyzerError] val,
    analyze_errors: ReadSeq[analyzer.AnalyzerError] val)
  =>
    _log(Fine) and _log.log(
      task_id.string() + ": file analyzed: " + canonical_path)
    if parse_errors.size() > 0 then
      _log(Fine) and _log.log(
        "  " + parse_errors.size().string() + " parse errors")
    end
    if lint_errors.size() > 0 then
      _log(Fine) and _log.log(
        "  " + lint_errors.size().string() + " lint errors")
    end
    if analyze_errors.size() > 0 then
      _log(Fine) and _log.log(
        "  " + analyze_errors.size().string() + " analyze errors")
    end

    match try _workspaces.by_analyzer(analyze)? end
    | let workspace: WorkspaceInfo =>
      _clear_errors(canonical_path, workspace.errors)
      _add_errors(parse_errors, workspace.errors)
      _add_errors(lint_errors, workspace.errors)
      _add_errors(analyze_errors, workspace.errors)

      if _client_data.text_document_publish_diagnostics() then
        if workspace.errors.contains(canonical_path) then
          try
            _log(Fine) and _log.log(
              task_id.string() + ": sending diagnostics for " + canonical_path)
            _notify_file_diagnostics(
              canonical_path, workspace.errors(canonical_path)?)
          end
        end
      end
    end

  be analyze_failed(
    analyze: analyzer.Analyzer,
    task_id: USize,
    canonical_path: String,
    errors: ReadSeq[analyzer.AnalyzerError] val)
  =>
    _log(Fine) and _log.log(
      task_id.string() + ": analyze failed: " + canonical_path)
