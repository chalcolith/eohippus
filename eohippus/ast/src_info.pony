use json = "../json"
use parser = "../parser"

primitive Inherited
primitive Reified
primitive Desugared

type SrcDerivation is (Inherited | Reified | Desugared)

class val SrcInfo is Equatable[SrcInfo]
  let locator: String
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

  fun eq(other: box->SrcInfo): Bool =>
    (start == other.start) and (next == other.next)

  fun ne(other: box->SrcInfo): Bool =>
    not this.eq(other)

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
