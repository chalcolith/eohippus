use "files"
use parser = "../parser"

interface tag Analyzer
  be open_file(task_id: USize, canonical_path: FilePath, parse: parser.Parser)
  be update_file(task_id: USize, canonical_path: FilePath, parse: parser.Parser)
  be close_file(task_id: USize, canonical_path: FilePath)
  be request_info(
    task_id: USize, canonical_path: FilePath, notify: AnalyzerRequestNotify)
  be dispose()
