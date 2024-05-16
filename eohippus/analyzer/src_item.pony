use "files"

use ast = "../ast"
use parser = "../parser"

primitive AnalysisStart
primitive AnalysisNeedsParse
primitive AnalysisParsing
primitive AnalysisNeedsLint
primitive AnalysisLinting
primitive AnalysisUpToDate
primitive AnalysisError

type SrcItemState is
  ( AnalysisStart
  | AnalysisNeedsParse
  | AnalysisParsing
  | AnalysisNeedsLint
  | AnalysisLinting
  | AnalysisUpToDate
  | AnalysisError )

class SrcItem
  let canonical_path: String
  let is_package: Bool

  var storage_prefix: String = ""
  var parent_package: (SrcItem | None) = None
  let dependencies: Array[SrcItem] = []

  var task_id: USize = 0
  var state: SrcItemState = AnalysisStart
  var is_open: Bool = false
  var schedule: (I64, I64) = (0, 0)
  var parse: (parser.Parser | None) = None
  var syntax_tree: (ast.Node | None) = None

  new create(
    canonical_path': String,
    is_package': Bool = false)
  =>
    canonical_path = canonical_path'
    is_package = is_package'
