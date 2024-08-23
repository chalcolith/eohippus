use "pony_test"

use ".."

primitive _TestStringUtil
  fun apply(test: PonyTest) =>
    test(_TestStringUtilUrlDecode)

class iso _TestStringUtilUrlDecode is UnitTest
  fun name(): String => "string_util/url_decode"
  fun exclusion_group(): String => "utils"

  fun apply(h: TestHelper) =>
    let url = "file:///c%3A/one/two"
    let expected = "file:///c:/one/two"
    let actual = StringUtil.url_decode(url)
    h.assert_eq[String](expected, actual)
