
use "itertools"
use "ponytest"

actor Main is TestList
  new create(env: Env) =>
    PonyTest(env, this)

  fun tag tests(test: PonyTest) =>
    test(_TestParserEOF)


primitive Tests
  fun to_utf16(str: String): ReadSeq[U16] =>
    // TODO: do actual UTF-8 conversion here
    let str16 = Array[U16](str.size())
    str16.concat(Iter[U8](str.values()).map[U16]({(ch) => ch.u16() }))
    str16
