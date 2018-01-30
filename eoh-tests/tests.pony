
use "ponytest"

actor Main is TestList
  new create(env: Env) =>
    None

  fun tag tests(test: PonyTest) =>
    test(_TestFileItemSeq01Simple)
