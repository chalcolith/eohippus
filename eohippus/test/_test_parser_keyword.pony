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
    let rule = recover val setup.builder.keyword("then") end

    let expected =
      """
        {
          "name": "Keyword",
          "string": "then"
        }
      """

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, "then", expected)
        _Assert.test_match(h, rule, setup.data, "boxing", None) ])

class iso _TestParserNotKeyword is UnitTest
  fun name(): String => "parser/keyword/notkeyword"
  fun exclusion_group(): String => "parser/keyword"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.keyword.not_kwd

    _Assert.test_all(
      h,
      [ _Assert.test_match(h, rule, setup.data, "then", None)
        _Assert.test_match(h, rule, setup.data, "baz", "")
        _Assert.test_match(h, rule, setup.data, "value", "") ])
