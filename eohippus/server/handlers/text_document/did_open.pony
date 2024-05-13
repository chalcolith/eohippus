use "files"
use "logger"

use rpc_data = "../../rpc/data"
use "../.."

class DidOpen
  let _log: Logger[String]
  let _server: Server
  let _config: ServerConfig

  new create(log: Logger[String], server: Server, config: ServerConfig) =>
    _log = log
    _server = server
    _config = config

  fun apply(
    auth: FileAuth,
    workspaces: Workspaces,
    src_files: SrcFiles,
    task_id: USize,
    params: rpc_data.DidOpenTextDocumentParams)
    : ((ServerState | None), (I32 | None))
  =>
    _log(Fine) and _log.log(
      task_id.string() + ": notification: textDocument/didOpen " +
      params.textDocument().uri())
    let src_file_info =
      if
        src_files.by_client_uri.contains(params.textDocument().uri())
      then
        try
          src_files.by_client_uri(params.textDocument().uri())?
        end
      else
        let info = SrcFileInfo(
          _log,
          auth,
          _server,
          params.textDocument().uri())
        src_files.by_client_uri.update(info.client_uri, info)

        if
          src_files.by_canonical_path.contains(info.canonical_path.path)
        then
          try
            let actual =
              src_files.by_canonical_path(info.canonical_path.path)?
            src_files.by_client_uri.update(params.textDocument().uri(), actual)
            actual
          end
        else
          src_files.by_canonical_path.update(
            info.canonical_path.path, info)
          info
        end
      end
    match src_file_info
    | let sfi: SrcFileInfo =>
      let parse = sfi.did_open(
        task_id,
        params.textDocument().version(),
        params.textDocument().text())
      let workspace = workspaces.get_workspace(
        auth, _config, sfi.canonical_path.path)
      workspace.analyze.open_file(task_id, sfi.canonical_path.path, parse)
    else
      _log(Error) and _log.log("unable to open " + params.textDocument().uri())
    end
    (None, None)
