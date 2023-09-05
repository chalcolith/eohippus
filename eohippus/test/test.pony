use "pony_test"

actor Main is TestList
  new create(env: Env) =>
    PonyTest(env, this)

  fun tag tests(test: PonyTest) =>
    _TestJson(test)
    _TestParserExpression(test)
    _TestParserKeyword(test)
    _TestParserLiteral(test)
    _TestParserSrcFile(test)
    _TestParserTrivia(test)
    _TestParserType(test)
    _TestParserTypedef(test)
