use json = "../json"
use parser = "../parser"

primitive Inherited
primitive Reified
primitive Desugared

type SrcDerivation is (Inherited | Reified | Desugared)

class val SrcInfo is Equatable[SrcInfo]
  """
    Source file span information.
    `locator`: an identifier for a source file or other source of code.
    `start`: the start location of the span.
    `next`: the location immediately after the span.
    `derived_from`: how this span is derived from original source.
  """

  let locator: parser.Locator
  let start: parser.Loc
  let next: parser.Loc

  let derived_from: ((SrcDerivation, Node) | None)

  new val create(
    locator': String,
    start': parser.Loc,
    next': parser.Loc,
    derived_from': ((SrcDerivation, Node)  | None) = None)
  =>
    locator = locator'
    start = start'
    next = next'
    derived_from = derived_from'

  new val from(
    orig: SrcInfo,
    locator': (parser.Locator | None) = None,
    start': (parser.Loc | None) = None,
    next': (parser.Loc | None) = None,
    derived_from': ((SrcDerivation, Node) | None) = None)
  =>
    locator =
      match locator'
      | let l: parser.Locator => l
      else orig.locator
      end
    start =
      match start'
      | let s: parser.Loc => s
      else orig.start
      end
    next =
      match next'
      | let n: parser.Loc => n
      else orig.next
      end
    derived_from =
      match derived_from'
      | (let sd: SrcDerivation, let n: Node) => (sd, n)
      else orig.derived_from
      end

  fun eq(other: box->SrcInfo): Bool =>
    (start == other.start) and (next == other.next)

  fun ne(other: box->SrcInfo): Bool =>
    not this.eq(other)

  fun length(): USize =>
    var len: USize = 0
    var cur = start
    while (cur != next) and cur.has_value() do
      cur = cur.next()
      len = len + 1
    end
    len

  fun literal_source(post: (NodeSeq | None) = None): String =>
    let next' =
      try
        (post as NodeSeq)(0)?.src_info().start
      else
        next
      end

    recover val
      String .> concat(start.values(next'))
    end
