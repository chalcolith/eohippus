
use "ponytest"
use "../eoh-parser"

class iso _Test_FileItem_Seq_01_Simple is UnitTest
  fun name(): String => "FileItem_Seq_01_Simple"
  fun label(): String => "FileItem"

  fun apply(h: TestHelper) =>
    let parser = PonyParser[U8].from_single_seq("a ")

    h.long_test(1_000_000_000)
