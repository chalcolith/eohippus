use "files"

primitive AnalyzeError
primitive AnalyzeWarning
primitive AnalyzeInfo
primitive AnalyzeHint

type AnalyzeSeverity is
  (AnalyzeError | AnalyzeWarning | AnalyzeInfo | AnalyzeHint)

class val AnalyzerError
  let canonical_path: FilePath
  let severity: AnalyzeSeverity
  let message: String
  let line: USize
  let column: USize
  let next_line: USize
  let next_column: USize

  new val create(
    canonical_path': FilePath,
    severity': AnalyzeSeverity,
    message': String,
    line': USize = 0,
    column': USize = 0,
    next_line': USize = 0,
    next_column': USize = 0)
  =>
    canonical_path = canonical_path'
    severity = severity'
    message = message'
    line = line'
    column = column'
    next_line = next_line'
    next_column = next_column'
