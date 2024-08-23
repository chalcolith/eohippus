"""

Eohippus is a collection of Pony packages and tools for dealing with Pony code.

## [AST](/eohippus/eohippus-ast--index/)

Classes that implement an abstract syntax tree for Pony code.

## [JSON](/eohippus/eohippus-json--index/)

Basic JSON functionality specialized for the needs of the project.

## [Linter](/eohippus/eohippus-linter--index/)

Functionality for detecting and fixing formatting issues in Pony code.

## [Parser](/eohippus/eohippus-parser--index/)

Implements a [Kiuatan](/kiuatan/kiuatan--index/) parser for the Pony language that produces an AST.

## [Server](/eohippus/eohippus-server--index)

A [Language Server Protocol](https://microsoft.github.io/language-server-protocol) implementation for Pony.

## [Types](/eohippus/eohippus-types--index/)

Contains classes that represent type information in the AST.

"""

use analyzer = "analyzer"
use ast = "ast"
use json = "json"
use linter = "linter"
use parser = "parser"
use server = "server"
use types = "types"

class _DocImports
  // Brings these types into the documentation
  let analyze: (analyzer.Analyzer | None) = None
  let ast_node: (ast.NodeWith[ast.Identifier] | None) = None
  let json_item: (json.Item | None) = None
  let linter_lint: (linter.Linter | None) = None
  let parser_builder: (parser.Builder | None) = None
  let server_server: (server.Server | None) = None
  let types_ast_type: (types.AstType | None) = None
