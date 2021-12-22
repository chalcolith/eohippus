use "ponytest"

actor Main is TestList
  new create(env: Env) =>
    PonyTest(env, this)

  fun tag tests(test: PonyTest) =>
    _TestParserTrivia(test)
    _TestParserLiteral(test)
    _TestParserExpression(test)
