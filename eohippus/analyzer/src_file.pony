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
  let canonical_path: FilePath
  let storage_prefix: String

  var state: SrcFileState = Unknown

  var in_memory_parse: (parser.Parser | None) = None
  var syntax_tree: (ast.SyntaxTree | None) = None

  new create(canonical_path': FilePath, storage_prefix': String) =>
    canonical_path = canonical_path'
    storage_prefix = storage_prefix'
