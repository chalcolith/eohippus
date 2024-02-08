"""

Eohippus is a collection of Pony packages and tools for dealing with Pony code.

## [AST](/eohippus/eohippus-ast--index/)

Contains classes that implement an abstract syntax tree for Pony code.

## [JSON](/eohippus/eohippus-json--index/)

Contains basic JSON functionality specialized for the needs of the project.

## [Parser](/eohippus/eohippus-parser--index/)

Implements a [Kiuatan](/kiuatan/kiuatan--index/) parser for the Pony language that produces an AST.

## [Types](/eohippus/eohippus-types--index/)

Contains classes that represent type information in the AST.

"""

use ast = "ast"
use json = "json"
use parser = "parser"
use types = "types"

class _DocImports
  // Brings these types into the documentation
  let node: (ast.NodeWith[ast.Identifier] | None) = None
  let item: (json.Item | None) = None
  let builder: (parser.Builder | None) = None
  let ast_type: (types.AstType | None) = None
