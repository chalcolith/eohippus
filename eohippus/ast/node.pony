use parser = "../parser"
use types = "../types"

trait val Node is (Equatable[Node] & Stringable)
  fun src_info(): SrcInfo

  fun start(): parser.Loc => src_info().start()
  fun next(): parser.Loc => src_info().next()

  fun eq(other: box->Node): Bool =>
    if (this.start() != other.start()) or (this.next() != other.next()) then
      return false
    end
    let a = String.concat(this.start().values(this.next()))
    let b = String.concat(other.start().values(other.next()))
    a == b

  fun ne(other: box->Node): Bool => not eq(other)

  fun string(): String iso^

trait val NodeTyped[N: NodeTyped[N]] is Node
  fun ast_type(): (types.AstType | None)
  fun val with_ast_type(ast_type': types.AstType): N

trait val NodeValued[V: Equatable[V] #read] is Node
  fun value(): V
  fun value_error(): Bool

trait val NodeParent is Node
  fun children(): ReadSeq[Node] val

class val Span is Node
  let _src_info: SrcInfo

  new val create(src_info': SrcInfo) =>
    _src_info = src_info'

  fun src_info(): SrcInfo => _src_info
  fun string(): String iso^ =>
    recover
      let s = String
      s.append("<SPAN '")
      for ch in _src_info.start().values(_src_info.next()) do
        if ch == ' ' then
          s.push(' ')
        elseif ch == '\n' then
          s.append("\\n")
        elseif ch == '\r' then
          s.append("\\r")
        elseif ch == '\t' then
          s.append("\\t")
        else
          s.push(ch)
        end
      end
      s.append("'>")
      s
    end
