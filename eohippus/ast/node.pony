use "itertools"

use json = "../json"
use types = "../types"

trait val NodeData
  fun name(): String

  fun add_json_props(props: Array[(String, json.Item)])

  fun json_seq[D: NodeData val = NodeData](seq: NodeSeqWith[D] val)
    : json.Sequence val
  =>
    recover val
      json.Sequence.from_iter(
        Iter[NodeWith[D]](seq.values())
          .map[json.Item val](
            {(n): json.Item val => n.get_json()}))
    end

trait val NodeDataWithValue[T: Any val] is NodeData
  fun value(): T

trait val Node
  fun src_info(): SrcInfo
  fun children(): NodeSeq
  fun error_section(): (NodeWith[ErrorSection] | None)
  fun annotation(): (NodeWith[Annotation] | None)
  fun doc_strings(): NodeSeqWith[DocString]
  fun pre_trivia(): NodeSeqWith[Trivia]
  fun post_trivia(): NodeSeqWith[Trivia]
  fun ast_type(): (types.AstType | None)
  fun get_json(): json.Item val
  fun string(): String iso^

class val NodeWith[D: NodeData val] is Node
  let _src_info: SrcInfo
  let _children: NodeSeq
  let _data: D
  let _error_section: (NodeWith[ErrorSection] | None)
  let _annotation: (NodeWith[Annotation] | None)
  let _doc_strings: NodeSeqWith[DocString]
  let _pre_trivia: NodeSeqWith[Trivia]
  let _post_trivia: NodeSeqWith[Trivia]
  let _ast_type: (types.AstType | None)

  new val create(
    src_info': SrcInfo,
    children': NodeSeq,
    data': D,
    error_section': (NodeWith[ErrorSection] | None) = None,
    annotation': (NodeWith[Annotation] | None) = None,
    doc_strings': NodeSeqWith[DocString] = [],
    pre_trivia': NodeSeqWith[Trivia] = [],
    post_trivia': NodeSeqWith[Trivia] = [],
    ast_type': (types.AstType | None) = None)
  =>
    _src_info = src_info'
    _children = children'
    _data = data'
    _error_section = error_section'
    _annotation = annotation'
    _doc_strings =
      if (doc_strings'.size() == 0) or
        Iter[NodeWith[DocString]](doc_strings'.values())
          .any({(n) => n.src_info().start < n.src_info().next })
      then
        doc_strings'
      else
        []
      end
    _pre_trivia =
      if (pre_trivia'.size() == 0) or
        Iter[NodeWith[Trivia]](pre_trivia'.values())
          .any({(n) => n.src_info().start < n.src_info().next })
      then
        pre_trivia'
      else
        []
      end
    _post_trivia =
      if (post_trivia'.size() == 0) or
        Iter[NodeWith[Trivia]](post_trivia'.values())
          .any({(n) => n.src_info().start < n.src_info().next })
      then
        post_trivia'
      else
        []
      end
    _ast_type = ast_type'

  fun src_info(): SrcInfo => _src_info

  fun children(): NodeSeq => _children

  fun data(): D => _data

  fun error_section(): (NodeWith[ErrorSection] | None) => _error_section

  fun doc_strings(): NodeSeqWith[DocString] => _doc_strings

  fun annotation(): (NodeWith[Annotation] | None) => _annotation

  fun pre_trivia(): NodeSeqWith[Trivia] => _pre_trivia

  fun post_trivia(): NodeSeqWith[Trivia] => _post_trivia

  fun ast_type(): (types.AstType | None) => _ast_type

  fun get_json(): json.Item val =>
    recover
      let props = [ as (String, json.Item): ("name", _data.name()) ]
      _data.add_json_props(props)
      // if _children.size() > 0 then
      //   props.push(("children", json_seq(_children)))
      // end
      match _error_section
      | let errsec: NodeWith[ErrorSection] =>
        props.push(("error_section", errsec.data().message))
      end
      if _doc_strings.size() > 0 then
        let ds_seq = json.Sequence.from_iter(
          Iter[NodeWith[DocString]](_doc_strings.values())
            .map[json.Item val](
              {(n: NodeWith[DocString]): json.Item val => n.get_json() }))
        props.push(("doc_strings", ds_seq))
      end
      if _pre_trivia.size() > 0 then
        let pt_seq = json.Sequence.from_iter(
          Iter[NodeWith[Trivia]](_pre_trivia.values())
            .map[json.Item val](
              {(n: NodeWith[Trivia]): json.Item val => n.get_json() }))
        props.push(("pre_trivia", pt_seq))
      end
      if _post_trivia.size() > 0 then
        let pt_seq = json.Sequence.from_iter(
          Iter[NodeWith[Trivia]](_post_trivia.values())
            .map[json.Item val](
              {(n: NodeWith[Trivia]): json.Item val => n.get_json() }))
        props.push(("post_trivia", pt_seq))
      end

      json.Object(props)
    end

  fun string(): String iso^ =>
    this.get_json().string()

type NodeSeq is ReadSeq[Node] val
type NodeSeqWith[D: NodeData val] is ReadSeq[NodeWith[D]] val

// trait val Node is (Equatable[Node] & Stringable)
//   fun src_info(): SrcInfo
//   fun has_error(): Bool

//   fun start(): parser.Loc => src_info().start()
//   fun next(): parser.Loc => src_info().next()

//   fun eq(other: box->Node): Bool =>
//     if (this.start() != other.start()) or (this.next() != other.next()) then
//       return false
//     end
//     let a = String.concat(this.start().values(this.next()))
//     let b = String.concat(other.start().values(other.next()))
//     a == b

//   fun ne(other: box->Node): Bool => not eq(other)

//   fun info(): json.Item val => recover json.Object([]) end
//   fun string(): String iso^ => this.info().string()

//   fun _info_seq[SN: Node val = Node](seq: ReadSeq[SN] val): json.Sequence val =>
//     recover val
//       json.Sequence(
//         Array[json.Item val](seq.size()).>concat(
//           Iter[SN](seq.values()).map[json.Item val]({(n: SN) => n.info()})))
//     end

// trait val NodeWithType[N: NodeWithType[N]] is Node
//   fun ast_type(): (types.AstType | None)
//   fun val with_ast_type(ast_type': types.AstType): N

// trait val NodeWithValue[V: Equatable[V] #read] is Node
//   fun has_error(): Bool => value_error()
//   fun value(): V
//   fun value_error(): Bool

// trait val NodeWithChildren is Node
//   fun has_error(): Bool =>
//     for child in children().values() do
//       if child.has_error() then return true end
//     end
//     false

//   fun _info_with_children(name: String): json.Item iso^ =>
//     let children' = _info_seq[Node](children())
//     recover iso
//       json.Object([
//         ("node", name)
//         ("children", children')
//       ])
//     end

//   fun children(): NodeSeq

// trait val NodeWithTrivia is Node
//   fun body(): Span
//   fun pre_trivia(): (Trivia | None) => None
//   fun post_trivia(): Trivia

// trait val NodeWithDocstring is Node
//   fun docstring(): NodeSeq[Docstring]

// trait val NodeWithName is Node
//   fun name(): String
