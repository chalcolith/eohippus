use "collections"
use "files"
use "logger"

use analyzer = "../analyzer"
use parser = "../parser"

class WorkspaceInfo
  let name: String
  let client_uri: String
  let canonical_path: FilePath
  let server: Server
  let analyze: analyzer.Analyzer

  let errors: Map[String, Array[analyzer.AnalyzerError]] = errors.create()

  new create(
    name': String,
    client_uri': String,
    canonical_path': FilePath,
    server': Server,
    analyze': analyzer.Analyzer)
  =>
    name = name'
    client_uri = client_uri'
    canonical_path = canonical_path'
    server = server'
    analyze = analyze'

class Workspaces
  let _log: Logger[String]
  let _server: Server
  let _grammar: parser.NamedRule val

  let by_client_uri: Map[String, WorkspaceInfo] =
    by_client_uri.create()
  let by_canonical_path: Map[String, WorkspaceInfo] =
    by_canonical_path.create()
  let by_analyzer: MapIs[analyzer.Analyzer, WorkspaceInfo] =
    by_analyzer.create()

  new create(
    log: Logger[String],
    server: Server,
    grammar: parser.NamedRule val)
  =>
    _log = log
    _server = server
    _grammar = grammar

  fun ref get_workspace(
    auth: FileAuth,
    config: ServerConfig,
    canonical_path: FilePath)
    : WorkspaceInfo?
  =>
    // TODO: refine this to handle multiple workspaces
    for (ws_path, workspace) in by_canonical_path.pairs() do
      return workspace
    end
    error

    // for (ws_path, workspace) in by_canonical_path.pairs() do
    //   if canonical_path.compare_sub(ws_path, ws_path.size()) is Equal then
    //     return workspace
    //   end
    // end

    // let workspace_path = FilePath(auth, Path.split(canonical_path)._1)
    // _log(Fine) and _log.log(
    //   "creating ad-hoc workspace for " + workspace_path.path)

    // let analyzer_context = analyzer.AnalyzerContext(

    // )

    // let ponyc =
    //   match config.ponyc_executable
    //   | let path: String =>
    //     FilePath(auth, path)
    //   end
    // let analyze = analyzer.EohippusAnalyzer(
    //   _log,
    //   auth,
    //   _grammar,
    //   FilePath(auth, dir),
    //   None,
    //   [],
    //   ponyc,
    //   None,
    //   _server)
    // let workspace = WorkspaceInfo(dir, dir, dir, _server, analyze)
    // by_canonical_path.update(dir, workspace)
    // by_analyzer.update(analyze, workspace)
    // workspace
