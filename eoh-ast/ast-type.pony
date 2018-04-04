
use "collections"
use "itertools"
use "kiuatan"

class AstScope[CH: (Unsigned & Integer[CH])]
  let parent: (AstScope[CH] val | None)
  let types: Map[String, AstType[CH] val] = types.create()

  new create(parent': (AstScope[CH] val | None)) =>
    parent = parent'


class AstType[CH: (Unsigned & Integer[CH])]
  let scope: AstScope[CH]
  let name: String
  let node: AstNode[CH]

  new create(scope': AstScope[CH], name': String, node': AstNode[CH]) =>
    scope = scope'
    name = name'
    node = node'
