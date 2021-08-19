use "ponytest"

actor Main is TestList
  new create(env: Env) =>
    PonyTest(env, this)

  fun tag tests(test: PonyTest) =>
    test(_TestParserTriviaEOF)
    test(_TestParserTriviaEOL)
    test(_TestParserTriviaWS)
    test(_TestParserLiteralBool)
