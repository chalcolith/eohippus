use "pony_test"

primitive _TestParserKeyword
  fun apply(test: PonyTest) =>
    test(_TestParserSingleKeyword)
    test(_TestParserNotKeyword)

class iso _TestParserSingleKeyword is UnitTest
  fun name(): String => "parser/keyword/single"
  fun exclusion_group(): String => "parser/keyword"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.keyword("then")
    h.fail()

    // let src = setup.src("then")
    // let expected = "{\n  \"node\": \"Keyword\",\n  \"name\": \"then\"\n}"

    // _Assert.test_all(h, [
    //   _Assert.test_json(h, rule, src, setup.data, expected)
    // ])

class iso _TestParserNotKeyword is UnitTest
  fun name(): String => "parser/keyword/notkeyword"
  fun exclusion_group(): String => "parser/keyword"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.expression.not_kwd()
    h.fail()

    // let src1 = setup.src("then")
    // let src2 = setup.src("baz")

    // _Assert.test_all(h, [
    //   _Assert.test_json(h, rule, src1, setup.data, None)
    //   _Assert.test_json(h, rule, src2, setup.data, "")
    // ])
