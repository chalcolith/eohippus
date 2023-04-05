use "itertools"

use json = "../json"
use parser = "../parser"
use types = "../types"

type NodeSeq[N: Node = Node] is ReadSeq[N] val

trait val Node is (Equatable[Node] & Stringable)
  fun src_info(): SrcInfo
  fun has_error(): Bool

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

  fun info(): json.Item val => recover json.Object([]) end
  fun string(): String iso^ => this.info().string()

  fun _info_seq[SN: Node val = Node](seq: ReadSeq[SN] val): json.Sequence val =>
    recover val
      json.Sequence(
        Array[json.Item val](seq.size()).>concat(
          Iter[SN](seq.values()).map[json.Item val]({(n: SN) => n.info()})))
    end

trait val NodeWithType[N: NodeWithType[N]] is Node
  fun ast_type(): (types.AstType | None)
  fun val with_ast_type(ast_type': types.AstType): N

trait val NodeWithValue[V: Equatable[V] #read] is Node
  fun has_error(): Bool => value_error()
  fun value(): V
  fun value_error(): Bool

trait val NodeWithChildren is Node
  fun has_error(): Bool =>
    for child in children().values() do
      if child.has_error() then return true end
    end
    false

  fun _info_with_children(name: String): json.Item iso^ =>
    let children' = _info_seq[Node](children())
    recover iso
      json.Object([
        ("node", name)
        ("children", children')
      ])
    end

  fun children(): NodeSeq

trait val NodeWithTrivia is Node
  fun body(): Span
  fun pre_trivia(): (Trivia | None) => None
  fun post_trivia(): Trivia

trait val NodeWithDocstring is Node
  fun docstring(): NodeSeq[Docstring]

trait val NodeWithName is Node
  fun name(): String
