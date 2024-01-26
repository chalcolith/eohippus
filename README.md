# Eohippus

Pony language compiler tools.

## Modules

### Parser

Contains the Builder class that constructs a grammar for the Pony language using
Kiuatan parser combinators.

### AST

Contains classes that comprise the abstract syntax tree returned by parsing
Pony source code.

### Types

Contains types to represent type information in an AST.

### JSON

Contains a basic implementation of parsing and generating JSON for debugging and
serializing ASTs.

### Lint

Contains functionality for detecting and fixing linting errors in ASTs.
