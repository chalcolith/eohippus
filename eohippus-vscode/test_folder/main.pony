// line comment
/* block comment */

use col = "collections"
use "package2"

actor Main
  """An actor in the test_folder package"""

  new create(env: Env) =>
    "Main constructor"

    let ch = 'c'
    let str = """triple string"""

    var foo = Foo
    for i in Range(1, 123) do
      foo.do(i)
    end

  be behavior() =>
    """Main behavior"""
    None

  fun function() =>
    "Main method"
    None

 !@#$%%

trait MainTrait
  "A trait in the test_folder package"
  fun trait_fun() => None

interface MainInterface
  "An interface in the test_folder package"

struct MainStruct
  "A struct in the test_folder package"

primitive MainPrimitive
  "A primitive in the test_folder package"
