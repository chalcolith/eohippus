
use "kiuatan"

trait val SrcNode[CH] is Stringable
  fun start(): Loc[CH]
  fun next(): Loc[CH]

  fun eq(other: SrcNode[CH]): Bool =>
    (this.start() == other.start()) and (this.next() == other.next())

  fun ne(other: SrcNode[CH]): Bool =>
    (this.start() != other.start()) or (this.next() != other.next())

  fun string(): String iso^


class val SrcTriviaWS[CH: (U8 | U16)] is SrcNode[CH]
  let _start: Loc[CH]
  let _next: Loc[CH]

  new val create(start': Loc[CH], next': Loc[CH]) =>
    _start = start'
    _next = next'

  fun start(): Loc[CH] => _start
  fun next(): Loc[CH] => _next

  fun string(): String iso^ =>
    recover
      let result = String
      result.append("<WS '")
      for ch in start().values(next()) do
        if ch.u8() == ' ' then
          result.append(" ")
        elseif ch.u8() == '\t' then
          result.append("\\t")
        else
          result.append("?")
        end
      end
      result.append("'>")
      result
    end


class val SrcTriviaEOL[CH] is SrcNode[CH]
  let _start: Loc[CH]
  let _next: Loc[CH]

  new val create(start': Loc[CH], next': Loc[CH]) =>
    _start = start'
    _next = next'

  fun start(): Loc[CH] => _start
  fun next(): Loc[CH] => _next

  fun string(): String iso^ =>
    recover
      String.>append("<EOL>")
    end


class val SrcTriviaEOF[CH] is SrcNode[CH]
  let _start: Loc[CH]
  let _next: Loc[CH]

  new val create(start': Loc[CH], next': Loc[CH]) =>
    _start = start'
    _next = next'

  fun start(): Loc[CH] => _start
  fun next(): Loc[CH] => _next

  fun string(): String iso^ =>
    recover
      String.>append("<EOF>")
    end
