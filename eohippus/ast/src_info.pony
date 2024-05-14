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
  let start: (parser.Loc | None)
  let next: (parser.Loc | None)
  let line: (USize | None)
  let column: (USize | None)
  let next_line: (USize | None)
  let next_column: (USize | None)
  let derived_from: ((SrcDerivation, Node) | None)

  new val create(
    locator': String,
    start': (parser.Loc | None) = None,
    next': (parser.Loc | None) = None,
    line': (USize | None) = None,
    column': (USize | None) = None,
    next_line': (USize | None) = None,
    next_column': (USize | None) = None,
    derived_from': ((SrcDerivation, Node)  | None) = None)
  =>
    locator = locator'
    start = start'
    next = next'
    line = line'
    column = column'
    next_line = next_line'
    next_column = next_column'
    derived_from = derived_from'

  new val from(
    orig: SrcInfo,
    locator': (parser.Locator | None) = None,
    start': (parser.Loc | None) = None,
    next': (parser.Loc | None) = None,
    line': (USize | None) = None,
    column': (USize | None) = None,
    next_line': (USize | None) = None,
    next_column': (USize | None) = None,
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
    line =
      match line'
      | let n: USize => n
      else orig.line
      end
    column =
      match column'
      | let n: USize => n
      else orig.column
      end
    next_line =
      match next_line'
      | let n: USize => n
      else orig.next_line
      end
    next_column =
      match next_column'
      | let n: USize => n
      else orig.next_column
      end
    derived_from =
      match derived_from'
      | (let sd: SrcDerivation, let n: Node) => (sd, n)
      else orig.derived_from
      end

  fun eq(other: box->SrcInfo): Bool =>
    if locator != other.locator then
      return false
    end
    match (start, next, other.start, other.next)
    | (let s': parser.Loc, let n': parser.Loc,
       let os': parser.Loc, let on': parser.Loc)
    =>
      return (s' == os') and (n' == on')
    end
    match (line, column, other.line, other.column)
    | (let l': USize, let c': USize, let ol': USize, let oc': USize) =>
      if (l' == ol') and (c' == oc') then
        match (next_line, next_column, other.next_line, other.next_column)
        | (let nl': USize, let nc': USize, let onl': USize, let onc': USize) =>
          (nl' == onl') and (nc' == onc')
        else
          true
        end
      end
    end
    false

  fun ne(other: box->SrcInfo): Bool =>
    not this.eq(other)

  fun length(): USize =>
    match (start, next)
    | (let start': parser.Loc, let next': parser.Loc) =>
      var len: USize = 0
      var cur = start'
      while (cur != next') and cur.has_value() do
        cur = cur.next()
        len = len + 1
      end
      len
    else
      0
    end

  fun literal_source(post: (NodeSeq | None) = None): String =>
    match (start, next)
    | (let start': parser.Loc, let next': parser.Loc) =>
      let next'' =
        match try (post as NodeSeq)(0)?.src_info().start end
        | let loc: parser.Loc =>
          loc
        else
          next
        end

        // match post
        // | let seq: NodeSeq if seq.size() > 0 =>
        //   match try seq(0)?.src_info() end
        //   | let si: SrcInfo =>
        //     match si.start
        //     | let loc: parser.Loc =>
        //       loc
        //     else
        //       next
        //     end
        //   else
        //     next
        //   end
        // else
        //   next
        // end
      recover val String .> concat(start'.values(next'')) end
    else
      ""
    end
