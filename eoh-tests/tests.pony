
use "ponytest"

use "kiuatan"
use "../eoh-ast"
use "../eoh-parser"

type CharParser is PonyParser[U8]
type CharParserResult is ParseResult[U8, AstNode[U8] val]
type CharParserResultOrError is
  ( CharParserResult val | ParseErrorMessage val | None)

actor Main is TestList
  new create(env: Env) =>
    PonyTest(env, this)

  fun tag tests(test: PonyTest) =>
    test(_TestLiteral01Bool)
