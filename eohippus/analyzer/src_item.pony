use "files"

use ast = "../ast"
use parser = "../parser"

primitive AnalysisStart
primitive AnalysisNeedsParse
primitive AnalysisParsing
primitive AnalysisError
primitive AnalysisUpToDate

type SrcItemState is
  ( AnalysisStart
  | AnalysisNeedsParse
  | AnalysisParsing
  | AnalysisError
  | AnalysisUpToDate )

class SrcItem
  let canonical_path: String
  let storage_prefix: String
  let is_package: Bool

  var task_id: USize = 0
  var state: SrcItemState = AnalysisStart
  var is_open: Bool = false
  var schedule: (I64, I64) = (0, 0)
  var parent_package: (SrcItem | None) = None
  var parse: (parser.Parser | None) = None
  var syntax_tree: (ast.SyntaxTree val | None) = None

  new create(
    canonical_path': String,
    storage_prefix': String,
    is_package': Bool = false)
  =>
    canonical_path = canonical_path'
    storage_prefix = storage_prefix'
    is_package = is_package'
