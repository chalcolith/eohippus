use "files"

use analyzer = "../analyzer"
use ast = "../ast"
use c_caps = "rpc/data/client_capabilities"
use parser = "../parser"
use rpc = "rpc"
use rpc_data = "rpc/data"
use tasks = "../analyzer/tasks"

interface tag Server is (analyzer.AnalyzerNotify & tasks.FindDefinitionNotify)
  be set_rpc_handler(rpc_handler: rpc.Handler)
  be rpc_listening()
  be rpc_connected()
  be rpc_error()
  be rpc_closed()
  be dispose()
  be exit()

  be notify_listening()
  be notify_connected()
  be notify_errored()
  be notify_initializing()
  be notify_initialized()
  be notify_received_request(id: (I128 | String | None), method: String)
  be notify_received_notification(method: String)
  be notify_sent_error(id: (I128 | String | None), code: I128, message: String)
  be notify_disconnected()
  be notify_shutting_down()
  be notify_exiting(code: I32)

  be request_initialize(
    message: rpc_data.RequestMessage,
    params: rpc_data.InitializeParams)
  be notification_initialized()
  be notification_set_trace(params: rpc_data.SetTraceParams)
  be notification_did_open_text_document(
    params: rpc_data.DidOpenTextDocumentParams)
  be notification_did_change_text_document(
    params: rpc_data.DidChangeTextDocumentParams)
  be notification_did_close_text_document(
    params: rpc_data.DidCloseTextDocumentParams)
  be request_definition(request_id: String, params: rpc_data.DefinitionParams)
  be request_shutdown(message: rpc_data.RequestMessage)
  be notification_exit()

  be set_client_data(
    capabilities: c_caps.ClientCapabilities,
    workspaceFolders: (Array[rpc_data.WorkspaceFolder] val | None),
    rootUri: (rpc_data.DocumentUri | None),
    rootPath: (String | None))
  be open_workspace(name: String, client_uri: String)

  be parsed_file(
      analyze: analyzer.Analyzer,
      task_id: USize,
      canonical_name: FilePath,
      syntax_tree: ast.Node,
      line_beginnings: ReadSeq[parser.Loc] val)

  be analyzed_workspace(
    analyze: analyzer.Analyzer,
    task_id: USize,
    workspace_errors: ReadSeq[analyzer.AnalyzerError] val,
    parse_errors: ReadSeq[analyzer.AnalyzerError] val,
    lint_errors: ReadSeq[analyzer.AnalyzerError] val,
    analyze_errors: ReadSeq[analyzer.AnalyzerError] val)
  be analyzed_file(
    analyze: analyzer.Analyzer,
    task_id: USize,
    canonical_path: FilePath,
    syntax_tree: (ast.Node | None),
    file_scope: (analyzer.Scope val | None),
    parse_errors: ReadSeq[analyzer.AnalyzerError] val,
    lint_errors: ReadSeq[analyzer.AnalyzerError] val,
    analyze_errors: ReadSeq[analyzer.AnalyzerError] val)
  be analyze_failed(
    analyze: analyzer.Analyzer,
    task_id: USize,
    canonical_path: FilePath,
    errors: ReadSeq[analyzer.AnalyzerError] val)

  // FindDefinitionNotify
  be definition_found(
    task_id: USize,
    canonical_path: FilePath,
    range: analyzer.SrcRange)
  be definition_failed(
    task_id: USize,
    message: String)
