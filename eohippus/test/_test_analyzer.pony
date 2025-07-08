use "files"
use "logger"
use "pony_test"

use analyzer = "../analyzer"
use ast = "../ast"
use json = "../json"
use parser = "../parser"
use server = "../server"

class iso _TestAnalyzerPlaceholder is UnitTest
  fun name(): String => "analyzer/placeholder"
  fun exclusion_group(): String => "analyzer"

  fun apply(h: TestHelper) =>
    h.complete(true)

primitive _TestAnalyzer
  fun apply(test: PonyTest, env: Env) =>
    let auth = FileAuth(env.root)
    let analyzer_tests_path =
      FilePath(
        auth,
        if Path.cwd().contains("build") then
          "../../eohippus/test/analyzer"
        else
          "./eohippus/test/analyzer"
        end)
    if not analyzer_tests_path.exists() then
      _fail(test, "no analyzer tests directory found; cwd is " + Path.cwd())
      return
    end
    let analyzer_tests_dir =
      try
        Directory(analyzer_tests_path)?
      else
        _fail(
          test,
          "analyzer tests path " + analyzer_tests_path.path +
            " is not a directory")
        return
      end
    try
      for entry in analyzer_tests_dir.entries()?.values() do
        let info = analyzer_tests_dir.infoat(entry)?
        if info.directory then
          let expected_path = info.filepath.join("expected")?
          if expected_path.exists() then
            test(_TestAnalyzerDirectory(
              env, entry, info.filepath, expected_path))
          end
        end
      end
    else
      _fail(test, "unable to process " + analyzer_tests_path.path)
      return
    end

  fun _fail(test: PonyTest, msg: String) =>
    let unit_test =
      object iso is UnitTest
        fun name(): String => "analyzer/SetupFailure"
        fun exclusion_group(): String => "analyzer"

        fun apply(h: TestHelper) =>
          h.fail("Analyzer tests failed: " + msg)
      end
    test(consume unit_test)

class iso _TestAnalyzerDirectory is UnitTest
  let _env: Env
  let _name: String
  let _workspace_path: FilePath
  let _expected_path: FilePath

  new iso create(
    env': Env,
    name': String,
    workspace_path': FilePath,
    expected_path': FilePath)
  =>
    _env = env'
    _name = name'
    _workspace_path = workspace_path'
    _expected_path = expected_path'

  fun name(): String => "analyzer/" + _name
  fun exclusion_group(): String => "analyzer"

  fun apply(h: TestHelper) =>
    let logger =
      Logger[String](
        Error,
        _env.err,
        {(s: String): String => s },
        server.EohippusLogFormatter)
    let parser_context = parser.Context([])
    let parser_grammar: parser.NamedRule val =
      parser.Builder(parser_context).src_file.src_file
    let workspace_cache =
      try
        _workspace_path.join(".eohippus")?
      else
        h.fail("unable to get workspace cache for " + _workspace_path.path)
        return
      end

    let notify = _AnalyzerTestNotify(
      h, _env, _workspace_path, workspace_cache, _expected_path)

    let analyzer_context = analyzer.AnalyzerContext(
      FileAuth(_env.root),
      _workspace_path,
      workspace_cache,
      workspace_cache,
      [],
      None,
      None,
      parser_grammar)
    let analyze = analyzer.EohippusAnalyzer(
      logger, analyzer_context, notify where include_libs = false)
    analyze.analyze()

    h.long_test(30_000_000_000)

actor _AnalyzerTestNotify
  let _h: TestHelper
  let _env: Env
  let _workspace_path: FilePath
  let _workspace_cache: FilePath
  let _expected_path: FilePath

  new create(
    h: TestHelper,
    env: Env,
    workspace_path: FilePath,
    workspace_cache: FilePath,
    expected_path: FilePath)
  =>
    _h = h
    _env = env
    _workspace_path = workspace_path
    _workspace_cache = workspace_cache
    _expected_path = expected_path

    if _workspace_cache.exists() then
      _workspace_cache.remove()
      _workspace_cache.mkdir()
    end

  be parsed_file(
    analyze: analyzer.Analyzer,
    task_id: USize,
    canonical_path: FilePath,
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
    if not (
      _print_errors(workspace_errors) or
      _print_errors(parse_errors) or
      _print_errors(lint_errors) or
      _print_errors(analyze_errors))
    then
      try
        let cache_dir = Directory(_workspace_cache)?
        let expected_dir = Directory(_expected_path)?

        for expected_entry in expected_dir.entries()?.values() do
          if expected_entry.trim(expected_entry.size()-5) == ".json" then
            let expected_fname =
              try
                expected_dir.path.join(expected_entry)?
              else
                _h.fail(
                  "unable to get entry " + expected_entry + " in " +
                  expected_dir.path.path)
                continue
              end
            let expected =
              match OpenFile(expected_fname)
              | let expected': File =>
                expected'
              else
                _h.fail(
                  "unable to open " + expected_dir.path.path + "/" +
                  expected_entry)
                continue
              end

            let actual_fname =
              try
                cache_dir.path.join(expected_entry)?
              else
                _h.fail(
                  "unable to get entry " + expected_entry + " in " +
                  cache_dir.path.path)
                continue
              end
            let actual =
              match OpenFile(actual_fname)
              | let actual': File =>
                actual'
              else
                _h.fail(
                  "unable to open " + cache_dir.path.path + "/" +
                  expected_entry)
                continue
              end

            let expected_str: String val = expected.read_string(expected.size())
            let expected_json =
              match json.Parse(expected_str)
              | let item: json.Item val =>
                item
              | let pe: json.ParseError =>
                _h.fail(expected_entry + ": " + pe.message)
                continue
              end

            let actual_str: String val = actual.read_string(actual.size())
            let actual_json =
              match json.Parse(actual_str)
              | let item: json.Item val =>
                item
              | let pe: json.ParseError =>
                _h.fail(expected_entry + ": " + pe.message)
                continue
              end

            (let ok, let err) =
              json.Subsumes(expected_json, actual_json)
            if not ok then
              _h.fail(expected_entry + " does not match: " + err)
            end
          end
        end
      else
        _h.fail("unable to process expected directory")
      end
    end
    _h.complete(true)

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
    None

  be analyze_failed(
    analyze: analyzer.Analyzer,
    task_id: USize,
    canonical_path: FilePath,
    errors: ReadSeq[analyzer.AnalyzerError] val)
  =>
    _print_errors(errors)
    _h.complete(false)

  fun _print_errors(errors: ReadSeq[analyzer.AnalyzerError] val) : Bool =>
    for e in errors.values() do
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
      _h.fail(
        e.canonical_path.path + ":" + (e.line + 1).string() + ":" +
        (e.column + 1).string() + ": " + kind + ": " + e.message)
    end
    errors.size() > 0
