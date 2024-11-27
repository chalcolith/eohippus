use "files"
use "logger"

use parser = "../parser"

class val AnalyzerContext
  let file_auth: FileAuth
  let workspace: FilePath
  let workspace_cache: FilePath
  let global_cache: FilePath
  let pony_path_dirs: ReadSeq[FilePath] val
  let ponyc_executable: (FilePath | None)
  let pony_packages_path: (FilePath | None)
  let grammar: parser.NamedRule val

  new val create(
    file_auth': FileAuth,
    workspace': FilePath,
    workspace_cache': FilePath,
    global_cache': FilePath,
    pony_path_dirs': ReadSeq[FilePath] val,
    ponyc_executable': (FilePath | None),
    pony_packages_path': (FilePath | None),
    grammar': parser.NamedRule val)
  =>
    file_auth = file_auth'
    workspace = workspace'
    workspace_cache = workspace_cache'
    global_cache = global_cache'
    pony_path_dirs = pony_path_dirs'
    ponyc_executable = ponyc_executable'
    pony_packages_path = pony_packages_path'

    grammar = grammar'

  fun get_cache(canonical_path: FilePath): FilePath =>
    let fcp = canonical_path.path
    let wsp = workspace.path
    let wsl = wsp.size()

    let comp =
      ifdef windows then
        fcp.compare_sub(wsp, wsl where ignore_case = true)
      else
        fcp.compare_sub(wsp, wsl)
      end

    if comp is Equal then
      return workspace_cache
    else
      return global_cache
    end
