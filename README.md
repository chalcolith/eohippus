# Eohippus

The Eohippus project contains some functionality for analysis of
[Pony programming language](https://ponylang.io) source code.  It is written
primarily in Pony itself.

The goals of this project are to eventually:

- Provide tools for analysis of Pony programs, suitable for use in formatters,
  as well as editors that can use the Language Server Protocol.
- Provide a front-end for incremental and parallelized Pony compilation.

> The project is at a very early stage.  Hardly any functionality is complete,
> but there exists enough to demonstrate some potential.
>
> Various parts of the code may be vastly over- or under-engineered.
>
> [Documentation](http://chalcolith.github.io/eohippus/eohippus--index/) is quite minimal.
>
> There is a basic test suite for the parser itself, but hardly anything else
> for other parts of the project.

The project contains the following parts:

## [AST](https://github.com/chalcolith/eohippus/tree/main/eohippus/ast)

Contains data structures for representing Pony code as an abstract syntax tree.

## [Parser](https://github.com/chalcolith/eohippus/tree/main/eohippus/parser)

This implements a [Kiuatan](https://github.com/chalcolith/kiuatan) parser for
parsing Pony source files.  It is a PEG parser (with left-recursion handling)
and can recover from errors in functions or classes.

> The parser is mostly complete, but fails to parse some of the Pony standard
> library files.  See #18

## [Analyzer](https://github.com/chalcolith/eohippus/tree/main/eohippus/analyzer)

Provides an actor that coordinates the analysis (currently parsing, scope
analysis, and linting) of a workspace containing Pony source files.

## [Linter](https://github.com/chalcolith/eohippus/tree/main/eohippus/linter)

Provides functionality for detcting formatting problems in Pony ASTs, and
fixing them.

> Currently the linter only knows about the `.editorconfig` standard rule
> `trim_trailing_whitespace`.

## [Formatter](https://github.com/chalcolith/eohippus/tree/main/eohippus-fmt)

A standalone executable that uses the linter to format Pony source files.

## [Language Server](https://github.com/chalcolith/eohippus/tree/main/eohippus/server)

An implementation of the [Language Server Protocol](https://microsoft.github.io/language-server-protocol/)
that uses Eohippus for analysis.

> The language server is currently very minimal; it provides:
>
> - Document synchronization: tracks changes to open files
> - Diagnostics: provides information about parsing and linting errors.
> - Go to definition: can find definitions for identifiers, but only in a single file, nor can it correctly handle qualified identifiers. See #19, #20

## [VSCode Extension](https://github.com/chalcolith/eohippus/tree/main/eohippus-vscode)

There exists the beginnings of a Visual Studio Code extension that uses the
language server.  It is not published yet, but it can be used for debugging the
parser, analyzer, and linter.

## API Documentation

Some source code documentation is [here](http://chalcolith.github.io/eohippus/eohippus--index/).

## Development

Working on Eohippus requires that you have [ponyc](https://github.com/ponylang/ponyc)
and [corral](https://github.com/ponylang/corral) in your PATH.  You can use the
[ponyup](https://github.com/ponylang/ponyup) tool to manage these.

### Building

On Unix:

- `make` builds the unit tests on Unix; `make config=debug` for debug mode.
- `make test` runs the unit tests.
- `make fmt` to build the formatter (`build/{release,debug}/eohippus-fmt`).
- `make lsp` to build the language server (`build/{release,debug}/eohippus-lsp`).

On Windows:

- `.\make.ps1 build -Target test` builds the unit tests; `.\make.ps1 build -Config debug -Target test` for debug mode.
- `.\make.ps1 test` runs the unit tests.
- `.\make.ps1 build -Target fmt` builds the formatter (`build\{release,debug}\eohippus-fmt.exe`).
- `.\make.ps1 build -Target lsp` builds the language server (`build\{release,debug}\eohippus-lsp`).

### Formatter

Usage: `build/release/eohippus-fmt [--verbose=false] [--fix=true] package_or_file`

- `--verbose=true` will print some information about what the formatter is doing.
- `--fix=true` (the default) will modify source files to fix formatting problems.

### Visual Studio Code Extension

In order to test the VSCode extension, you will need to build `eohippus-lsp`.
You will also need to run `npm install` in the [eohippus-vscode](https://github.com/chalcolith/eohippus/tree/main/eohippus-vscode) directory before your first use.

Then go to the "Run and Debug" pane in VSCode and run the `Debug VSCode Extension`
configuration.  This will open a new instance of VSCode that has the extension loaded, in a [test folder](https://github.com/chalcolith/eohippus/tree/main/eohippus-vscode/test_folder) that contains some example Pony files.

If the extension is working and can connect to the language server, you should
see a folder called `.eohippus` appear in the test folder.  This contains cached
representations of the various stages of analysis.
