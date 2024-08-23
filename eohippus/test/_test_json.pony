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
    let seq = json.Sequence([ as json.Item: "one"; F64(3.14) ])

    let a = json.Object(
      [ as (String, json.Item):
        ("a", seq)
        ("b", "bravo") ])

    let d = json.Object([ as (String, json.Item): ("d", false) ])

    let b = json.Object(
      [ as (String, json.Item):
        ("c", d)
        ("a", seq)
        ("b", "bravo") ])

    h.assert_true(json.Subsumes(a, b)._1, "a should subsume b")
    h.assert_false(json.Subsumes(a, d)._1, "a should not subsume d")

    let one = json.Object(
      [ as (String, json.Item):
        ("name", "LiteralFloat" )
        ("value", I128(456)) ])
    let two = json.Object(
      [ as (String, json.Item):
        ("value", I128(456))
        ("name", "LiteralFloat") ])
    h.assert_true(json.Subsumes(one, two)._1)

  class iso _TestJsonParse is UnitTest
    fun name(): String => "json/Parse"
    fun exclusion_group(): String => "json"

    fun _test(h: TestHelper, source: String, expected: json.Item) =>
      let items = Array[json.Item]
      let perrs = Array[json.ParseError]

      let parser = json.Parser
      parser.parse_seq(source, items, perrs)
      parser.parse_seq([0], items, perrs)
      try
        let item = items(0)?
        (var res, var err) = json.Subsumes(item, expected)
        h.assert_true(
          res,
          "'" + item.string() + "' does not subsume '" + expected.string() +
            "': " + err)
        (res, err) = json.Subsumes(expected, item)
        h.assert_true(
          res,
          "'" + expected.string() + "' does not subsume '" + item.string() +
            "': " + err)
      else
        if perrs.size() > 0 then
          try
            let perr = perrs(0)?
            h.fail(perr.message + " at index " + perr.index.string())
          end
        else
          h.fail("JSON parse failed")
        end
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
      _test(h, "{}", json.Object)
      _test(h, "[]", json.Sequence)

      let exp1 = json.Object([ as (String, json.Item): ("a", I128(123)) ])
      _test(h, """{ "a": 123 }""", exp1)

      let seq2 = json.Sequence([ as json.Item: I128(1); I128(2); I128(3) ])
      let obj2 = json.Object([ as (String, json.Item): ("d", false) ])
      let exp2 = json.Object(
        [ as (String, json.Item):
          ("a", "str")
          ("b", seq2)
          ("c", obj2) ])

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

      let exp3 = json.Object(
        [ as (String, json.Item):
          ("name", "Identifier")
          ("string", "a1_'") ])
      let source3 = """ { "name": "Identifier", "string": "a1_'" } """
      _test(h, source3, exp3)

      let exp4 = json.Object(
        [ as (String, json.Item):
          ("foo", json.Null)
          ("bar", json.Sequence([ as json.Item: "a"; json.Null]))])
      let source4 = """{ "foo": null, "bar": [ "a", null ]}"""
      _test(h, source4, exp4)

      let exp5 = json.Object(
        [ as (String, json.Item):
          ("foo", json.Sequence([ as json.Item: I128(1); I128(2) ])) ])
      let source5 = """{"foo":[1,2]}"""
      _test(h, source5, exp5)
