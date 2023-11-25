use "collections/persistent"

use json = "../json"
use parser = "../parser"
use types = "../types"

class _TestSetup
  let context: parser.Context
  let builder: parser.Builder val
  let data: parser.Data

  new create(name: String) =>
    context = parser.Context(recover Array[types.AstPackage val] end)
    builder = recover val parser.Builder(context) end
    data = parser.Data(name)

  fun src(str: String): List[parser.Segment] =>
    Lists[parser.Segment]([ str ])
