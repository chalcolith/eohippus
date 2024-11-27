use "appdirs"
use "files"
use "logger"

use analyzer = "../eohippus/analyzer"
use ast = "../eohippus/ast"
use parser = "../eohippus/parser"
use server = "../eohippus/server"

actor Main
  let _env: Env
  let _auth: FileAuth

  new create(env: Env) =>
    _env = env
    _auth = FileAuth(env.root)

    let logger =
      ifdef debug then
        Logger[String](
          Fine,
          env.err,
          {(s: String): String => s },
          server.EohippusLogFormatter)
      else
        Logger[String](
          Error,
          env.err,
          {(s: String): String => s },
          server.EohippusLogFormatter)
      end

    let parser_context = parser.Context([])
    let parser_grammar: parser.NamedRule val =
      parser.Builder(parser_context).src_file.src_file

    let workspace_dir =
      try
        env.args(1)?
      else
        Path.cwd()
      end

    let workspace_path = FilePath(_auth, workspace_dir)
    env.err.print("workspace_path: " + workspace_path.path)

    let workspace_cache = FilePath(
      _auth, Path.join(workspace_path.path, ".eohippus"))
    if not _check_cache(workspace_cache, "workspace cache") then
      return
    end
    env.err.print("workspace_cache: " + workspace_cache.path)

    let appdirs = AppDirs(env.vars, "eohippus")
    let global_cache =
      try
        FilePath(_auth, appdirs.user_cache_dir()?)
      else
        env.err.print("unable to get user cache dir")
        return
      end
    if not _check_cache(global_cache, "global_cache") then
      return
    end
    env.err.print("global_cache: " + global_cache.path)

    let pony_path_dirs = server.ServerUtils.get_pony_path_dirs(env)
    env.err.print("pony_path_dirs:")
    for path in pony_path_dirs.values() do
      env.err.print("  " + path.path)
    end

    let ponyc = server.ServerUtils.find_ponyc(env)
    match ponyc
    | let ponyc_path: FilePath =>
      env.err.print("ponyc_path: " + ponyc_path.path)
    else
      env.err.print("ponyc_path: None")
    end

    let pony_packages = server.ServerUtils.find_pony_packages(env, ponyc)
    match pony_packages
    | let pony_packages_path: FilePath =>
      env.err.print("pony_packages_path: " + pony_packages_path.path)
    else
      env.err.print("pony_packages_path: None")
    end

    let analyzer_context = analyzer.AnalyzerContext(
      FileAuth(env.root),
      workspace_path,
      workspace_cache,
      global_cache,
      pony_path_dirs,
      ponyc,
      pony_packages,
      parser_grammar)

    let analyze = analyzer.EohippusAnalyzer(logger, analyzer_context, this)
    analyze.analyze()

  fun _check_cache(path: FilePath, name: String): Bool =>
    try
      if (not path.exists()) and (not path.mkdir()) then
        _env.err.print(
          "unable to create " + name + ": " + path.path)
        return false
      end
      let info = FileInfo(path)?
      if not info.directory then
        _env.err.print(name + " is not a directory: " + path.path)
        return false
      end
    else
      _env.err.print("unable to access " + name + ": " + path.path)
      return false
    end
    true

  be parsed_file(
    analyze: analyzer.Analyzer,
    task_id: USize,
    canonical_name: FilePath,
    syntax_tree: ast.Node,
    line_beginnings: ReadSeq[parser.Loc] val)
  =>
    None

  be analyzed_workspace(
    analyze: analyzer.Analyzer,
    task_id: USize,
    workspace_errors: ReadSeq[analyzer.AnalyzerError] val,
    parse_errors: ReadSeq[analyzer.AnalyzerError] val,
    lint_errors: ReadSeq[analyzer.AnalyzerError] val,
    analyze_errors: ReadSeq[analyzer.AnalyzerError] val)
  =>
    print_errors(workspace_errors, None)

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
    print_errors(parse_errors, canonical_path)
    print_errors(analyze_errors, canonical_path)
    print_errors(lint_errors, canonical_path)

  be analyze_failed(
    analyze: analyzer.Analyzer,
    task_id: USize,
    canonical_path: FilePath,
    errors: ReadSeq[analyzer.AnalyzerError] val)
  =>
    print_errors(errors, canonical_path)

  fun print_errors(
    errors: ReadSeq[analyzer.AnalyzerError] val,
    path: (FilePath | None))
  =>
    for e in errors.values() do
      match path
      | let path': FilePath =>
        if e.canonical_path.path != path'.path then
          continue
        end
      end

      let kind =
        match e.severity
        | analyzer.AnalyzeError =>
          "ERROR"
        | analyzer.AnalyzeWarning =>
          "WARNING"
        | analyzer.AnalyzeInfo =>
          "INFO"
        | analyzer.AnalyzeHint =>
          "HINT"
        end
      _env.err.print(
        e.canonical_path.path + ":" + (e.line + 1).string() + ":" +
        (e.column + 1).string() + ": " + kind + ": " + e.message)
    end
