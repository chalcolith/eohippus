use "pony_test"

use json = "../json"

primitive _TestJson
  fun apply(test: PonyTest) =>
    test(_TestJsonSubsumes)
    test(_TestJsonParse)

class iso _TestJsonSubsumes is UnitTest
  fun name(): String => "json/Subsumes"
  fun exclusion_group(): String => "json"

  fun apply(h: TestHelper) =>
    let seq =
      recover val
        json.Sequence([ "one"; F64(3.14) ])
      end

    let a =
      recover val
        json.Object(
          [ ("a", seq)
            ("b", "bravo") ])
      end

    let d =
      recover val
        json.Object([ ("d", false) ])
      end

    let b =
      recover val
        json.Object(
          [ ("c", d)
            ("a", seq)
            ("b", "bravo") ])
      end

    h.assert_true(json.Subsumes(a, b), "a should subsume b")
    h.assert_false(json.Subsumes(a, d), "a should not subsume d")

    let one =
      recover val
        json.Object([ ("name", "LiteralFloat" ); ("value", I128(456)) ])
      end
    let two =
      recover val
        json.Object([ ("value", I128(456)); ("name", "LiteralFloat") ])
      end
    h.assert_true(json.Subsumes(one, two))

  class iso _TestJsonParse is UnitTest
    fun name(): String => "json/Parse"
    fun exclusion_group(): String => "json"

    fun _test(h: TestHelper, source: String, expected: json.Item) =>
      match json.Parse(source)
      | let item: json.Item =>
        h.assert_true(json.Subsumes(item, expected))
        h.assert_true(json.Subsumes(expected, item))
      | let err: json.ParseError =>
        h.fail(
          "Parse failed: " + err.message + " at index " + err.index.string())
      end

    fun apply(h: TestHelper) =>
      _test(h, "true", true)
      _test(h, "false", false)
      _test(h, "123", I128(123))
      _test(h, "-123", I128(-123))
      _test(h, "123.456", F64(123.456))
      _test(h, "-123.456", F64(-123.456))
      _test(h, "1.23e45", F64(1.23e+45))
      _test(h, "1.23e-45", F64(1.23e-45))
      _test(h, "\"foo\"", "foo")
      _test(h, "\"foo\tbar\"", "foo\tbar")
      _test(h, "\"foo\\ufffdbar\"", "foo\uFFFDbar")

      let exp1 =
        recover val
          json.Object([ ("a", I128(123)) ])
        end
      _test(h, """{ "a": 123 }""", exp1)

      let seq2 = recover val json.Sequence([ I128(1); I128(2); I128(3) ]) end
      let obj2 = recover val json.Object([ ("d", false) ]) end
      let exp2 =
        recover val
          json.Object(
            [ ("a", "str")
              ("b", seq2)
              ("c", obj2) ])
        end

      let source2 =
        """
          {
            "a": "str",
            "b": [
              1,
              2,
              3
            ],
            "c": {
              "d": false
            }
          }
        """
      _test(h, source2, exp2)
