use "collections"
use "files"
use "logger"
use "time"

use analyzer = "../analyzer"
use ast = "../ast"
use json = "../json"
use parser = "../parser"
use req = "requests"
use rpc = "rpc"
use rpc_data = "rpc/data_types"
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

  let _workspaces_by_client_uri: Map[String, ServerWorkspace] =
    _workspaces_by_client_uri.create()
  let _workspaces_by_canonical_path: Map[String, ServerWorkspace] =
    _workspaces_by_canonical_path.create()
  let _workspaces_by_analyzer: MapIs[analyzer.Analyzer, ServerWorkspace] =
    _workspaces_by_analyzer.create()

  let _src_files_by_client_uri: Map[String, SrcFileInfo] =
    _src_files_by_client_uri.create()
  let _src_files_by_canonical_path: Map[String, SrcFileInfo] =
    _src_files_by_canonical_path.create()

  let _handle_initialize: req.Initialize
  let _handle_shutdown: req.Shutdown

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

    _handle_initialize = req.Initialize(_log, this)
    _handle_shutdown = req.Shutdown(_log, this)

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

    for workspace in _workspaces_by_client_uri.values() do
      workspace.analyze.dispose()
    end
    _workspaces_by_client_uri.clear()
    _workspaces_by_canonical_path.clear()
    _workspaces_by_analyzer.clear()

  be exit() =>
    if _state isnt ServerExiting then
      _log(Info) and _log.log("server exiting with code " + _exit_code.string())
      // make sure things are cleaned up
      _state = ServerExiting
      _env.exitcode(_exit_code)
      notify_exiting(_exit_code)
    end

  be request_initialize(
    message: rpc_data.RequestMessage,
    params: rpc_data.InitializeParams)
  =>
    _handle_request(_handle_initialize(_state, _rpc_handler, message, params))

  be request_shutdown(message: rpc_data.RequestMessage) =>
    _handle_request(_handle_shutdown(_state, _rpc_handler, message))

  fun ref _handle_request(status: ((ServerState | None), (I32 | None))) =>
    match status._1
    | let state: ServerState =>
      _state = state
    end
    match status._2
    | let exit_code: I32 =>
      _exit_code = exit_code
    end

  be notification_initialized() =>
    _log(Fine) and _log.log("notification: initialized")
    notify_received_notification("initialized")
    if _state is ServerInitializing then
      _state = ServerInitialized
      notify_initialized()
    else
      _log(Error) and _log.log("initialized notification when not initializing")
    end

  be notification_set_trace(params: rpc_data.SetTraceParams) =>
    _log(Fine) and _log.log("trace value set")
    _trace_value = params.value()

  be notification_did_open_text_document(
    params: rpc_data.DidOpenTextDocumentParams)
  =>
    _log(Fine) and _log.log("notification: textDocument/didOpen " +
      params.textDocument().uri())
    // let src_file_info =
    //   if
    //     _src_files_by_client_uri.contains(params.textDocument().uri())
    //   then
    //     try
    //       _src_files_by_client_uri(params.textDocument().uri())?
    //     end
    //   else
    //     let info = SrcFileInfo(
    //       _log,
    //       this,
    //       _parser_grammar,
    //       FileAuth(_env.root),
    //       params.textDocument().uri())
    //     _src_files_by_client_uri.update(info.client_uri, info)

    //     if
    //       _src_files_by_canonical_path.contains(info.canonical_file_path.path)
    //     then
    //       try
    //         let actual =
    //           _src_files_by_canonical_path(info.canonical_file_path.path)?
    //         _src_files_by_client_uri.update(params.textDocument().uri(), actual)
    //         actual
    //       end
    //     else
    //       _src_files_by_canonical_path.update(
    //         info.canonical_file_path.path, info)
    //       info
    //     end
    //   end
    // match src_file_info
    // | let sfi: SrcFileInfo =>
    //   sfi.is_open_in_client = true
    //   sfi.did_open(
    //     _get_next_task_id(),
    //     params.textDocument().version(),
    //     params.textDocument().text())
    // else
    //   _log(Error) and _log.log("unable to open " + params.textDocument().uri())
    // end

  be notification_did_change_text_document(
    params: rpc_data.DidChangeTextDocumentParams)
  =>
    _log(Fine) and _log.log("notification: textDocument/didChange")
    // let uri = params.textDocument().uri()
    // try
    //   let info = _src_files_by_client_uri(uri)?
    //   info.did_change(
    //     _get_next_task_id(),
    //     params.textDocument(),
    //     params.contentChanges())
    // else
    //   _log(Error) and _log.log("no open info found for " + uri)
    // end

  be notification_did_close_text_document(
    params: rpc_data.DidCloseTextDocumentParams)
  =>
    _log(Fine) and _log.log("notification: textDocument/didClose")
    // let uri = params.textDocument().uri()
    // try
    //   let info = _src_files_by_client_uri(uri)?
    //   info.did_close()
    // else
    //   _log(Error) and _log.log("no info found for " + uri)
    // end

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

  be open_workspace(name: String, client_uri: String) =>
    _log(Fine) and _log.log("open workspace " + name + " " + client_uri)
    if not _workspaces_by_client_uri.contains(client_uri) then
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
      let workspace = ServerWorkspace(
        name, client_uri, canonical_path.path, analyze)
      _workspaces_by_client_uri.update(client_uri, workspace)
      _workspaces_by_canonical_path.update(canonical_path.path, workspace)
      _workspaces_by_analyzer.update(analyze, workspace)
    else
      _log(Warn) and _log.log("workspace " + client_uri + " already open")
    end

  be schedule_parse(task_id: USize, canonical_path: String) =>
    _log(Warn) and _log.log("DEPRECATED SCHEDULE_PARSE")

  be start_parse(task_id: USize, canonical_path: String) =>
    _log(Warn) and _log.log("DEPRECATED START_PARSE")

  be parse_succeeded(
    task_id: USize,
    canonical_path: String,
    node: ast.NodeWith[ast.SrcFile])
  =>
    _log(Warn) and _log.log("DEPRECATED PARSE_SUCCEEDED")

  be analyzed_workspace(
    analyze: analyzer.Analyzer,
    task_id: USize,
    package_errors: ReadSeq[analyzer.AnalyzerError] val,
    parse_errors: ReadSeq[analyzer.AnalyzerError] val,
    lint_errors: ReadSeq[analyzer.AnalyzerError] val,
    analyze_errors: ReadSeq[analyzer.AnalyzerError] val)
  =>
    _log(Fine) and _log.log(task_id.string() + ": workspace analyzed")

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
    _log(Fine) and _log.log(task_id.string() + ": file analyzed")

  be analyze_failed(
    analyze: analyzer.Analyzer,
    task_id: USize,
    canonical_path: String,
    errors: ReadSeq[analyzer.AnalyzerError] val)
  =>
    _log(Fine) and _log.log(task_id.string() + ": analyze failed")
