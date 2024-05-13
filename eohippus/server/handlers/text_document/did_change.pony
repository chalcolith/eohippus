use "files"
use "logger"

use parser = "../../../parser"
use rpc_data = "../../rpc/data"
use "../.."

class DidChange
  let _log: Logger[String]
  let _config: ServerConfig

  new create(log: Logger[String], config: ServerConfig) =>
    _log = log
    _config = config

  fun apply(
    auth: FileAuth,
    workspaces: Workspaces,
    src_files: SrcFiles,
    task_id: USize,
    params: rpc_data.DidChangeTextDocumentParams)
    : ((ServerState | None), (I32 | None))
  =>
    _log(Fine) and _log.log(
      task_id.string() + "notification : textDocument/didChange")
    let uri = params.textDocument().uri()
    try
      let info = src_files.by_client_uri(uri)?
      info.did_change(
        task_id,
        params.textDocument(),
        params.contentChanges())
      let workspace = workspaces.get_workspace(
        auth, _config, info.canonical_path.path)
      match info.parse
      | let parse': parser.Parser =>
        workspace.analyze.update_file(task_id, info.canonical_path.path, parse')
      end
    else
      _log(Error) and _log.log(
        task_id.string() +  ": no open info found for " + uri)
    end
    (None, None)
