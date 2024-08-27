use "collections"
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
  var scope: (Scope val | None) = None

  var node_indices: MapIs[ast.Node, USize] val = node_indices.create()
  var nodes_by_index: Map[USize, ast.Node] val = nodes_by_index.create()

  new create(canonical_path': String) =>
    canonical_path = canonical_path'

  fun path(): String => canonical_path
  fun state_value(): USize => state()

  fun ref make_indices() =>
    match syntax_tree
    | let node: ast.Node =>
      (node_indices, nodes_by_index) =
        recover val
          let ni = MapIs[ast.Node, USize]
          let nbi = Map[USize, ast.Node]
          var next_index: USize = 0
          _make_indices(
            node, ni, nbi, { ref () => next_index = next_index + 1 })
          (ni, nbi)
        end
    end

  fun tag _make_indices(
    node: ast.Node,
    ni: MapIs[ast.Node, USize],
    nbi: Map[USize, ast.Node],
    get_next: { ref (): USize})
  =>
    let index = get_next()
    ni(node) = index
    nbi(index) = node
    for child in node.children().values() do
      _make_indices(child, ni, nbi, get_next)
    end

class SrcPackageItem
  let canonical_path: String

  var storage_prefix: String = ""
  var is_workspace: Bool = false
  var parent_package: (SrcPackageItem | None) = None
  let dependencies: Array[SrcItem] = []

  var task_id: USize = 0
  var state: SrcItemState = AnalysisStart

  new create(canonical_path': String) =>
    canonical_path = canonical_path'

  fun path(): String => canonical_path
  fun state_value(): USize => state()
