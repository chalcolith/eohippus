use "files"

use ast = "../ast"
use parser = "../parser"

primitive AnalysisStart
  fun apply(): USize => 0

primitive AnalysisParsing
  fun apply(): USize => 1

primitive AnalysisScoping
  fun apply(): USize => 2

primitive AnalysisLinting
  fun apply(): USize => 3

primitive AnalysisUpToDate
  fun apply(): USize => 1000

primitive AnalysisError
  fun apply(): USize => USize.max_value()

type SrcItemState is
  ( AnalysisStart
  | AnalysisParsing
  | AnalysisScoping
  | AnalysisLinting
  | AnalysisUpToDate
  | AnalysisError )

type SrcItem is (SrcFileItem | SrcPackageItem)

class SrcFileItem
  let canonical_path: String

  var storage_prefix: String = ""
  var parent_package: (SrcPackageItem | None) = None
  let dependencies: Array[SrcItem] = []

  var task_id: USize = 0
  var state: SrcItemState = AnalysisStart
  var is_open: Bool = false
  var schedule: (I64, I64) = (0, 0)
  var parse: (parser.Parser | None) = None
  var syntax_tree: (ast.Node | None) = None
  var scope: (Scope | None) = None

  new create(canonical_path': String) =>
    canonical_path = canonical_path'

  fun state_value(): USize => state()

class SrcPackageItem
  let canonical_path: String

  var storage_prefix: String = ""
  var is_workspace: Bool = false
  var parent_package: (SrcPackageItem | None) = None
  let dependencies: Array[SrcItem] = []

  var task_id: USize = 0
  var state: SrcItemState = AnalysisStart
  var scope: (Scope | None) = None

  new create(canonical_path': String) =>
    canonical_path = canonical_path'

  fun state_value(): USize => state()
