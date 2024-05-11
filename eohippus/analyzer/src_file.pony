use "files"

use ast = "../ast"
use parser = "../parser"

primitive Unknown
primitive NeedsParse
primitive Parsing
primitive ParseError
primitive UpToDate

type SrcFileState is (Unknown | NeedsParse | Parsing | ParseError | UpToDate)

class SrcFile
  let canonical_path: String
  let storage_prefix: String

  var task_id: USize = 0
  var state: SrcFileState = Unknown
  var is_open: Bool = false
  var schedule: (I64, I64) = (0, 0)
  var parse: (parser.Parser | None) = None
  var syntax_tree: (ast.SyntaxTree val | None) = None

  new create(
    canonical_path': String,
    storage_prefix': String)
  =>
    canonical_path = canonical_path'
    storage_prefix = storage_prefix'
