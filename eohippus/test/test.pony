use "pony_test"

actor Main is TestList
  let _env: Env

  new create(env: Env) =>
    _env = env
    PonyTest(_env, this)

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

    // This is a workaround for running test --only=analyzer
    // If there's no tests in this method, things go wrong
    test(_TestAnalyzerPlaceholder)
    _analyzer_tests(test)

  be _analyzer_tests(test: PonyTest) =>
    _TestAnalyzer(test, _env)
