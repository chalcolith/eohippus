use "files"
use "logger"

use rpc_data = "../../rpc/data"
use "../.."

class DidClose
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
    params: rpc_data.DidCloseTextDocumentParams)
    : ((ServerState | None), (I32 | None))
  =>
    _log(Fine) and _log.log(
      task_id.string() + ": notification: textDocument/didClose")
    let uri = params.textDocument().uri()
    try
      let info = src_files.by_client_uri(uri)?
      let workspace = workspaces.get_workspace(
        auth, _config, info.canonical_path.path)
      workspace.analyze.close_file(task_id, info.canonical_path.path)
      src_files.by_client_uri.remove(uri)?
      src_files.by_canonical_path.remove(info.canonical_path.path)?
    else
      _log(Error) and _log.log(task_id.string() + ": no info found for " + uri)
    end
    (None, None)
