use "appdirs"
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

  let _pending_requests: Map[USize, String]

  let _handle_text_document_did_open: handle_text_document.DidOpen
  let _handle_text_document_did_change: handle_text_document.DidChange
  let _handle_text_document_did_close: handle_text_document.DidClose
  let _handle_text_document_definition: handle_text_document.Definition

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

    _pending_requests = Map[USize, String]

    _handle_initialize = handlers.Initialize(_log, this)
    _handle_shutdown = handlers.Shutdown(_log, this)
    _handle_text_document_did_open = handle_text_document.DidOpen(
      _log, this, _config)
    _handle_text_document_did_change = handle_text_document.DidChange(
      _log, _config)
    _handle_text_document_did_close = handle_text_document.DidClose(
      _log, _config)
    _handle_text_document_definition = handle_text_document.Definition(
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

  be request_definition(
    request_id: String,
    params: rpc_data.DefinitionParams)
  =>
    let canonical_path = _get_canonical_path(params.textDocument().uri())
    let task_id = _get_next_task_id()
    _pending_requests.update(task_id, request_id)
    _handle_request(
      _handle_text_document_definition(
        FileAuth(_env.root), _workspaces, task_id, params, canonical_path))

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
    _log(Fine) and _log.log("opening workspace " + name + " " + client_uri)
    if not _workspaces.by_client_uri.contains(client_uri) then
      let auth = FileAuth(_env.root)

      let workspace_path = _get_canonical_path(client_uri)
      if not workspace_path.exists() then
        _log(Error) and _log.log(
          "workspace does not exist: " + workspace_path.path)
        return
      end
      _log(Fine) and _log.log("workspace_path: " + workspace_path.path)

      let workspace_cache = FilePath(
        auth, Path.join(workspace_path.path, ".eohippus"))
      if not _check_cache(workspace_cache, "workspace cache") then
        return
      end
      _log(Fine) and _log.log("workspace_cache: " + workspace_cache.path)

      let appdirs = AppDirs(_env.vars, "eohippus")
      let global_cache =
        try
          FilePath(auth, appdirs.user_cache_dir()?)
        else
          _log(Error) and _log.log("unable to get user cache dir")
          return
        end
      if not _check_cache(global_cache, "global_cache") then
        return
      end
      _log(Fine) and _log.log("global_cache: " + global_cache.path)

      let pony_path_dirs = ServerUtils.get_pony_path_dirs(_env)
      _log(Fine) and _log.log("pony_path_dirs:")
      for path in pony_path_dirs.values() do
        _log(Fine) and _log.log("  " + path.path)
      end

      let ponyc =
        match _config.ponyc_executable
        | let ponyc_path: FilePath =>
          if ponyc_path.exists() then
            ponyc_path
          end
        else
          ServerUtils.find_ponyc(_env)
        end
      match ponyc
      | let ponyc_path: FilePath =>
        _log(Fine) and _log.log("ponyc_path: " + ponyc_path.path)
      else
        _log(Fine) and _log.log("ponyc_path: None")
      end

      let pony_packages = ServerUtils.find_pony_packages(_env, ponyc)
      match pony_packages
      | let pony_packages_path: FilePath =>
        _log(Fine) and _log.log(
          "pony_packages_path: " + pony_packages_path.path)
      else
        _log(Fine) and _log.log("pony_packages_path: None")
      end

      let analyzer_context = analyzer.AnalyzerContext(
        auth,
        workspace_path,
        workspace_cache,
        global_cache,
        pony_path_dirs,
        ponyc,
        pony_packages,
        _parser_grammar)

      let analyze = analyzer.EohippusAnalyzer(_log, analyzer_context, this)
      analyze.analyze()

      let workspace = WorkspaceInfo(
        name, client_uri, workspace_path, this, analyze)
      _workspaces.by_client_uri.update(client_uri, workspace)
      _workspaces.by_canonical_path.update(workspace_path.path, workspace)
      _workspaces.by_analyzer.update(analyze, workspace)
    else
      _log(Warn) and _log.log("workspace " + client_uri + " already open")
    end

  fun _check_cache(path: FilePath, name: String): Bool =>
    try
      if (not path.exists()) and (not path.mkdir()) then
        _log(Error) and _log.log("unable to create " + name + ": " + path.path)
        return false
      end
      let info = FileInfo(path)?
      if not info.directory then
        _log(Error) and _log.log(name + " is not a directory: " + path.path)
        return false
      end
    else
      _log(Error) and _log.log("unable to access " + name + ": " + path.path)
      return false
    end
    true

  fun _clear_errors(
    canonical_path: FilePath,
    dest: Map[String, Array[analyzer.AnalyzerError]])
  =>
    try
      let map = dest(canonical_path.path)?
      map.clear()
      map.compact()
    end

  fun _add_errors(
    src: ReadSeq[analyzer.AnalyzerError],
    dest: Map[String, Array[analyzer.AnalyzerError]])
  =>
    for err in src.values() do
      let arr =
        try
          dest(err.canonical_path.path)?
        else
          let arr' = Array[analyzer.AnalyzerError]
          dest(err.canonical_path.path) = arr'
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
    canonical_path_str: String,
    errors: Array[analyzer.AnalyzerError])
  =>
    let client_uri = StringUtil.get_client_uri(canonical_path_str)
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
    for canonical_path_str in errors.keys() do
      try
        _notify_file_diagnostics(
          canonical_path_str, errors(canonical_path_str)?)
      end
      num_sent = num_sent + 1
    end
    _log(Fine) and _log.log(
      "textDocument/publishDiagnostics: sent " + num_sent.string())

  be parsed_file(
    analyze: analyzer.Analyzer,
    task_id: USize,
    canonical_path: FilePath,
    syntax_tree: ast.Node,
    line_beginnings: ReadSeq[parser.Loc] val)
  =>
    match try _src_files.by_canonical_path(canonical_path.path)? end
    | let src_file: SrcFileInfo =>
      _log(Fine) and _log.log(
        task_id.string() + ": parsed " + canonical_path.path)
      src_file.syntax_tree = syntax_tree
      src_file.set_line_beginnings(line_beginnings)
    else
      _log(Fine) and _log.log(
        task_id.string() + " parsed unknown " + canonical_path.path)
    end

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
    canonical_path: FilePath,
    syntax_tree: (ast.Node | None),
    file_scope: (analyzer.Scope val | None),
    parse_errors: ReadSeq[analyzer.AnalyzerError] val,
    lint_errors: ReadSeq[analyzer.AnalyzerError] val,
    analyze_errors: ReadSeq[analyzer.AnalyzerError] val)
  =>
    _log(Fine) and _log.log(
      task_id.string() + ": file analyzed: " + canonical_path.path)
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
        try
          _log(Fine) and _log.log(
            task_id.string() + ": sending diagnostics for " +
            canonical_path.path)
          _notify_file_diagnostics(
            canonical_path.path, workspace.errors(canonical_path.path)?)
        end
      end
    end

  be analyze_failed(
    analyze: analyzer.Analyzer,
    task_id: USize,
    canonical_path: FilePath,
    errors: ReadSeq[analyzer.AnalyzerError] val)
  =>
    _log(Fine) and _log.log(
      task_id.string() + ": analyze failed: " + canonical_path.path)

  fun ref _get_request_id(task_id: USize): (I128 | String | None) =>
    let result =
      try
        let req_str = _pending_requests(task_id)?
        try
          req_str.i128()?
        else
          req_str
        end
      end
    try _pending_requests.remove(task_id)? end
    result

  be definition_found(
    task_id: USize,
    canonical_path: FilePath,
    range: analyzer.SrcRange)
  =>
    let client_uri = StringUtil.get_client_uri(canonical_path.path)
    let request_id = _get_request_id(task_id)
    let start' =
      object val is rpc_data.Position
        fun val line(): I128 => I128.from[USize](range._1)
        fun val character(): I128 => I128.from[USize](range._2)
      end
    let endd' =
      object val is rpc_data.Position
        fun val line(): I128 => I128.from[USize](range._3)
        fun val character(): I128 => I128.from[USize](range._4)
      end
    let range' =
      object val is rpc_data.Range
        fun val start(): rpc_data.Position => start'
        fun val endd(): rpc_data.Position => endd'
      end
    let result_data =
      object val is rpc_data.Location
        fun val uri(): rpc_data.DocumentUri => client_uri
        fun val range(): rpc_data.Range => range'
      end
    let response =
      object val is rpc_data.ResponseMessage
        fun val id(): (I128 | String | None) => request_id
        fun val result(): (rpc_data.ResultData | None) => result_data
      end
    _rpc_handler.respond(response)

  be definition_failed(
    task_id: USize,
    message: String)
  =>
    let request_id = _get_request_id(task_id)
    _rpc_handler.respond_error(request_id, 1, message)
