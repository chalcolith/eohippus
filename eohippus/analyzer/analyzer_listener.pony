interface AnalyzerListener
  be file_analyzed(
    task_id: USize,
    canonical_path: String,
    syntax_tree: (ast.SyntaxTree | None),
    file_scope: (FileScope | None),
    parse_errors: ReadSeq[AnalyzerError] val,
    lint_errors: ReadSeq[AnalyzerError] val,
    analyzer_errors: ReadSeq[AnalyzerError] val)

  be analyze_failed(
    task_id: USize,
    canonical_path: String,
    errors: ReadSeq[AnalyzerError] val)

  be errors_reported(
    task_id: USize,
    errors: ReadSeq[AnalyzerError] val)
