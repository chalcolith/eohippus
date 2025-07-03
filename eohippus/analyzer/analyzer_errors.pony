use "collections"
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

primitive AnalyzerWorkspaceErrors
  fun apply(): USize => 0

primitive AnalyzerParseErrors
  fun apply(): USize => 1

primitive AnalyzerLintErrors
  fun apply(): USize => 2

primitive AnalyzerAnalyzeErrors
  fun apply(): USize => 3

type AnalyzerErrorsArea is
  ( AnalyzerWorkspaceErrors
  | AnalyzerParseErrors
  | AnalyzerLintErrors
  | AnalyzerAnalyzeErrors )

type AnalyzerErrorMap is Map[String, Array[AnalyzerError]]

class AnalyzerErrors
  let _errors: Array[AnalyzerErrorMap]

  new create() =>
    _errors = Array[AnalyzerErrorMap](AnalyzerAnalyzeErrors() + 1)

  fun ref clear() =>
    for error_map in _errors.values() do
      error_map.clear()
      error_map.compact()
    end

  fun ref push_error(
    area: AnalyzerErrorsArea,
    err: AnalyzerError,
    clear_array: Bool = false)
  =>
    let map = try _errors(area())? else return end
    let arr =
      match try map(err.canonical_path.path)? end
      | let arr': Array[AnalyzerError] =>
        if clear_array then
          arr'.clear()
          arr'.compact()
        end
        arr'
      else
        let arr' = Array[AnalyzerError]
        map(err.canonical_path.path) = arr'
        arr'
      end
    arr.push(err)

  fun ref clear_errors(area: AnalyzerErrorsArea, canonical_path: FilePath) =>
    let map = try _errors(area())? else return end
    try
      map.remove(canonical_path.path)?
      map.compact()
    end

  fun ref collect_area_errors(
    area: AnalyzerErrorsArea,
    canonical_path: (FilePath | None) = None)
    : Array[AnalyzerError] val
  =>
    let map = try _errors(area())? else return [] end

    let results: Array[AnalyzerError] trn = Array[AnalyzerError]
    match canonical_path
    | let canonical_path': FilePath =>
      try
        for err in map(canonical_path'.path)?.values() do
          results.push(err)
        end
      end
    else
      for (_, arr) in map.pairs() do
        for err in arr.values() do
          results.push(err)
        end
      end
    end
    consume results

  fun ref collect_path_errors(canonical_path: FilePath)
    : Array[AnalyzerError] val
  =>
    let results: Array[AnalyzerError] trn = Array[AnalyzerError]
    for map in _errors.values() do
      try
        for err in map(canonical_path.path)?.values() do
          results.push(err)
        end
      end
    end
    consume results
