use "pony_test"

use json = "../json"

primitive _TestJson
  fun apply(test: PonyTest) =>
    test(_TestJsonString)

class iso _TestJsonString is UnitTest
  fun name(): String => "json/String"
  fun exclusion_group(): String => "json"

  fun apply(h: TestHelper) =>
    let x =
      recover val
        json.Sequence([ "mu"; true ])
      end
    let z =
      recover val
        json.Object([
          ("o", F64(678.9))
          ("p", "psi")
        ])
      end
    let c =
      recover val
        json.Object([
          ("x", x)
          ("y", "upsilon")
          ("z", z)
        ])
      end
    let obj = json.Object([
      ("a", F64(123.456))
      ("b", false)
      ("c", c)
    ])

    var expected: String val =
      """
        {
          "a": 123.456,
          "b": false,
          "c": {
            "x": [
              "mu",
              true
            ],
            "y": "upsilon",
            "z": {
              "o": 678.9,
              "p": "psi"
            }
          }
        }
      """
    expected = expected.clone().>strip("\r\n")

    let actual: String val = obj.string()

    let exp: String val = expected.clone().>replace("\r\n", "\\n")
    let act: String val = actual.clone().>replace("\n", "\\n")
    // h.log("expected: '" + exp + "'")
    // h.log("actual:   '" + act + "'")

    h.assert_eq[String](exp, act)
