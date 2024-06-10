use "files"
use "logger"

use rpc_data = "../../rpc/data"
use "../.."

class Definition
  let _log: Logger[String]
  let _config: ServerConfig

  new create(log: Logger[String], config: ServerConfig) =>
    _log = log
    _config = config

  fun apply(
    auth: FileAuth,
    workspaces: Workspaces,
    task_id: USize,
    params: rpc_data.DefinitionParams,
    canonical_path: String)
    : ((ServerState | None), (I32 | None))
  =>
    _log(Fine) and _log.log(
      task_id.string() + ": request definition: " +
      params.textDocument().uri() + ":" + params.position().line().string() +
      ":" + params.position().character().string())
    let uri = params.textDocument().uri()
    let workspace = workspaces.get_workspace(auth, _config, canonical_path)
    let position = params.position()
    workspace.analyze.find_definition(
      task_id,
      canonical_path,
      USize.from[I128](position.line()),
      USize.from[I128](position.character()))
    (None, None)
