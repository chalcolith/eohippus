class val AnalyzerError
  let canonical_path: String
  let line: USize
  let column: USize
  let message: String

  new val create(
    canonical_path': String,
    line': USize,
    column': USize,
    message': String)
  =>
    canonical_path = canonical_path'
    line = line'
    column = column'
    message = message'
