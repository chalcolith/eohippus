use "files"
use "logger"

use analyzer = "../eohippus/analyzer"
use ast = "../eohippus/ast"
use parser = "../eohippus/parser"
use server = "../eohippus/server"

actor Main
  let _env: Env
  let _auth: FileAuth
  let _context: parser.Context
  let _grammar: parser.NamedRule val

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

    _context = parser.Context([])
    _grammar = parser.Builder(_context).src_file.src_file

    let pony_path = server.ServerUtils.get_pony_path(env)
    let ponyc = server.ServerUtils.find_ponyc(env)

    let workspace_dir =
      try
        env.args(1)?
      else
        Path.cwd()
      end

    let workspace_path = FilePath(_auth, workspace_dir)

    env.err.print("workspace_path " + workspace_path.path)

    analyzer.EohippusAnalyzer(
      logger,
      _auth,
      _grammar,
      workspace_path,
      None,
      pony_path,
      ponyc,
      None,
      this)

  be parsed_file(
    analyze: analyzer.Analyzer,
    task_id: USize,
    canonical_name: String,
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
    canonical_path: String,
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
    canonical_path: String,
    errors: ReadSeq[analyzer.AnalyzerError] val)
  =>
    print_errors(errors, canonical_path)

  fun print_errors(
    errors: ReadSeq[analyzer.AnalyzerError] val,
    path: (String | None))
  =>
    for e in errors.values() do
      match path
      | let path': String =>
        if e.canonical_path != path' then
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
        e.canonical_path + ":" + (e.line + 1).string() + ":" +
        (e.column + 1).string() + ": " + kind + ": " + e.message)
    end
