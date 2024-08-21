use ast = "../ast"
use parser = "../parser"

interface tag AnalyzerNotify
  be parsed_file(
    analyze: Analyzer,
    task_id: USize,
    canonical_name: String,
    syntax_tree: ast.Node,
    line_beginnings: ReadSeq[parser.Loc] val)

  be analyzed_workspace(
    analyze: Analyzer,
    task_id: USize,
    workspace_errors: ReadSeq[AnalyzerError] val,
    parse_errors: ReadSeq[AnalyzerError] val,
    lint_errors: ReadSeq[AnalyzerError] val,
    analyze_errors: ReadSeq[AnalyzerError] val)

  be analyzed_file(
    analyze: Analyzer,
    task_id: USize,
    canonical_path: String,
    syntax_tree: (ast.Node | None),
    file_scope: (Scope val | None),
    parse_errors: ReadSeq[AnalyzerError] val,
    lint_errors: ReadSeq[AnalyzerError] val,
    analyze_errors: ReadSeq[AnalyzerError] val)

  be analyze_failed(
    analyze: Analyzer,
    task_id: USize,
    canonical_path: String,
    errors: ReadSeq[AnalyzerError] val)

interface tag AnalyzerRequestNotify
  be request_succeeded(
    task_id: USize,
    canonical_path: String,
    syntax_tree: (ast.Node | None),
    scope: Scope val)

  be request_failed(
    task_id: USize,
    canonical_path: String,
    message: String)
