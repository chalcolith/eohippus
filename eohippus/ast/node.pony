use "itertools"

use json = "../json"
use types = "../types"

primitive Nodes
  fun get_json(seq: NodeSeq): json.Sequence val =>
    recover val
      json.Sequence.from_iter(
        Iter[Node](seq.values())
          .map[json.Item val](
            {(n): json.Item val => n.get_json()}))
    end

trait val NodeData
  fun name(): String

  fun add_json_props(props: Array[(String, json.Item)])

trait val NodeDataWithValue[T: Any val] is NodeData
  fun value(): T

trait val Node
  fun src_info(): SrcInfo
  fun children(): NodeSeq
  fun annotation(): (NodeWith[Annotation] | None)
  fun doc_strings(): NodeSeqWith[DocString]
  fun pre_trivia(): NodeSeqWith[Trivia]
  fun post_trivia(): NodeSeqWith[Trivia]
  fun error_sections(): NodeSeqWith[ErrorSection]
  fun ast_type(): (types.AstType | None)
  fun get_json(): json.Item val
  fun string(): String iso^

class val NodeWith[D: NodeData val] is Node
  let _src_info: SrcInfo
  let _children: NodeSeq
  let _data: D
  let _annotation: (NodeWith[Annotation] | None)
  let _doc_strings: NodeSeqWith[DocString]
  let _pre_trivia: NodeSeqWith[Trivia]
  let _post_trivia: NodeSeqWith[Trivia]
  let _error_sections: NodeSeqWith[ErrorSection]
  let _ast_type: (types.AstType | None)

  new val create(
    src_info': SrcInfo,
    children': NodeSeq,
    data': D,
    annotation': (NodeWith[Annotation] | None) = None,
    doc_strings': NodeSeqWith[DocString] = [],
    pre_trivia': NodeSeqWith[Trivia] = [],
    post_trivia': NodeSeqWith[Trivia] = [],
    error_sections': NodeSeqWith[ErrorSection] = [],
    ast_type': (types.AstType | None) = None)
  =>
    _src_info = src_info'
    _children = children'
    _data = data'
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
    _error_sections =
      if (error_sections'.size() == 0) or
        Iter[NodeWith[ErrorSection]](error_sections'.values())
          .any({(n) => n.src_info().start < n.src_info().next })
      then
        error_sections'
      else
        []
      end
    _ast_type = ast_type'

  new val with_annotation(
    orig: NodeWith[D],
    ann: (NodeWith[Annotation] | None))
  =>
    _src_info = orig._src_info
    _children = orig._children
    _data = orig._data
    _annotation = ann
    _doc_strings = orig._doc_strings
    _pre_trivia = orig._pre_trivia
    _post_trivia = orig._post_trivia
    _error_sections = orig._error_sections
    _ast_type = orig._ast_type

  fun src_info(): SrcInfo => _src_info

  fun children(): NodeSeq => _children

  fun data(): D => _data

  fun doc_strings(): NodeSeqWith[DocString] => _doc_strings

  fun annotation(): (NodeWith[Annotation] | None) => _annotation

  fun pre_trivia(): NodeSeqWith[Trivia] => _pre_trivia

  fun post_trivia(): NodeSeqWith[Trivia] => _post_trivia

  fun error_sections(): NodeSeqWith[ErrorSection] => _error_sections

  fun ast_type(): (types.AstType | None) => _ast_type

  fun get_json(): json.Item val =>
    recover
      let props = [ as (String, json.Item): ("name", _data.name()) ]
      _data.add_json_props(props)
      if _error_sections.size() > 0 then
        props.push(("error_sections", Nodes.get_json(_error_sections)))
      end
      if _pre_trivia.size() > 0 then
        props.push(("pre_trivia", Nodes.get_json(_pre_trivia)))
      end
      if _doc_strings.size() > 0 then
        props.push(("doc_strings", Nodes.get_json(_doc_strings)))
      end
      if _post_trivia.size() > 0 then
        props.push(("post_trivia", Nodes.get_json(_post_trivia)))
      end
      json.Object(props)
    end

  fun string(): String iso^ =>
    this.get_json().string()

type NodeSeq is ReadSeq[Node] val
type NodeSeqWith[D: NodeData val] is ReadSeq[NodeWith[D]] val
