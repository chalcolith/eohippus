use analyzer = "../analyzer"

class ServerWorkspace
  let name: String
  let client_uri: String
  let canonical_path: String
  let analyze: analyzer.Analyzer

  let parse_errors: Array[analyzer.AnalyzerError] = []
  let lint_errors: Array[analyzer.AnalyzerError] = []
  let analyze_errors: Array[analyzer.AnalyzerError] = []

  new create(
    name': String,
    client_uri': String,
    canonical_path': String,
    analyze': analyzer.Analyzer)
  =>
    name = name'
    client_uri = client_uri'
    canonical_path = canonical_path'
    analyze = analyze'
