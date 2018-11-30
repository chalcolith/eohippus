
use "ponytest"
use ".."

class iso _TestParserEOF is UnitTest
  fun name(): String => "Test_Parser_EOF"

  fun apply(h: TestHelper) =>
    let context = Context[U8]
    let builder = Builder[U8](context)
    let rule = builder.eof()


