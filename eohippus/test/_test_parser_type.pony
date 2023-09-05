use "pony_test"

use ast = "../ast"
use json = "../json"
use parser = "../parser"
use ".."

primitive _TestParserType
  fun apply(test: PonyTest) =>
    test(_TestParserTypeArrow)

class iso _TestParserTypeArrow is UnitTest
  fun name(): String => "parser/type/TypeArrow"
  fun exclusion_group(): String => "parser/type"

  fun apply(h: TestHelper) =>
    let setup = _TestSetup(name())
    let rule = setup.builder.type_type.arrow()

    let source = "this->N"
    let expected =
      """
        {
          "name": "TypeArrow",
          "lhs": {
            "name": "TypeAtom",
            "body": {
              "name": "Keyword",
              "string": "this"
            }
          },
          "rhs": {
            "name": "TypeNominal",
            "rhs": {
              "name": "Identifier",
              "string": "N"
            }
          }
        }
      """

    _Assert.test_all(h,
      [ _Assert.test_match(h, rule, setup.data, source, expected) ])
