use "pony_test"

actor Main is TestList
  new create(env: Env) =>
    PonyTest(env, this)

  fun tag tests(test: PonyTest) =>
    _TestAstParseNode(test)
    _TestAstSyntaxTree(test)
    _TestJson(test)
    _TestLanguageServer(test)
    _TestLanguageServerTcp(test)
    _TestLinter(test)
    _TestParserExpression(test)
    _TestParserKeyword(test)
    _TestParserLiteral(test)
    _TestParserSrcFile(test)
    _TestParserTrivia(test)
    _TestParserType(test)
    _TestParserTypedef(test)
    _TestStringUtil(test)
    _TestQueue(test)
