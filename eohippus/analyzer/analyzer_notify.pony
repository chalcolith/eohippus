use ast = "../ast"

interface tag AnalyzerNotify
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
    syntax_tree: (ast.SyntaxTree val | None),
    file_scope: (SrcFileScope | None),
    parse_errors: ReadSeq[AnalyzerError] val,
    lint_errors: ReadSeq[AnalyzerError] val,
    analyze_errors: ReadSeq[AnalyzerError] val)

  be analyze_failed(
    analyze: Analyzer,
    task_id: USize,
    canonical_path: String,
    errors: ReadSeq[AnalyzerError] val)
