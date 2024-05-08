use "itertools"

use json = "../json"
use parser = "../parser"
use types = "../types"

class val NodeWith[D: NodeData val] is Node
  """An AST node with specific semantic data."""

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
    _children =
      recover val
        Array[Node].>concat(
          Iter[Node](children'.values())
            .filter({(n) =>
              match n
              | let t: NodeWith[Trivia] =>
                if t.data().kind is EndOfFileTrivia then
                  return true
                end
                match (t.src_info().start, t.src_info().next)
                | (let s': parser.Loc, let n': parser.Loc) =>
                  s' < n'
                else
                  true
                end
              else
                true
              end
            }))
      end
    _data = data'
    _annotation = annotation'
    _doc_strings =
      if (doc_strings'.size() == 0) or
        Iter[NodeWith[DocString]](doc_strings'.values())
          .any(
            {(n) =>
              match (n.src_info().start, n.src_info().next)
              | (let s': parser.Loc, let n': parser.Loc) =>
                s' < n'
              else
                true
              end
            })
      then
        doc_strings'
      else
        []
      end
    _pre_trivia =
      if (pre_trivia'.size() == 0) or
        Iter[NodeWith[Trivia]](pre_trivia'.values())
          .any(
            {(n) =>
              if n.data().kind is EndOfFileTrivia then
                return true
              end
              match (n.src_info().start, n.src_info().next)
              | (let s': parser.Loc, let n': parser.Loc) =>
                s' < n'
              else
                true
              end
            })
      then
        pre_trivia'
      else
        []
      end
    _post_trivia =
      if (post_trivia'.size() == 0) or
        Iter[NodeWith[Trivia]](post_trivia'.values())
          .any(
            {(n) =>
              if n.data().kind is EndOfFileTrivia then
                return true
              end
              match (n.src_info().start, n.src_info().next)
              | (let s': parser.Loc, let n': parser.Loc) =>
                s' < n'
              else
                true
              end
            })
      then
        post_trivia'
      else
        []
      end
    _error_sections =
      if (error_sections'.size() == 0) or
        Iter[NodeWith[ErrorSection]](error_sections'.values())
          .any(
            {(n) =>
              match (n.src_info().start, n.src_info().next)
              | (let s': parser.Loc, let n': parser.Loc) =>
                s' < n'
              else
                true
              end
            })
      then
        error_sections'
      else
        []
      end
    _ast_type = ast_type'

  new val from(
    orig: NodeWith[D],
    src_info': (SrcInfo | None) = None,
    children': (NodeSeq | None) = None,
    data': (D | None) = None,
    annotation': (NodeWith[Annotation] | None) = None,
    doc_strings': (NodeSeqWith[DocString] | None) = None,
    pre_trivia': (NodeSeqWith[Trivia] | None) = None,
    post_trivia': (NodeSeqWith[Trivia] | None) = None,
    error_sections': (NodeSeqWith[ErrorSection] | None) = None,
    ast_type': (types.AstType | None) = None)
  =>
    _src_info =
      match src_info'
      | let si: SrcInfo => si
      else orig._src_info
      end
    _children =
      match children'
      | let ch: NodeSeq => ch
      else orig._children
      end
    _data =
      match data'
      | let d: D => d
      else orig._data
      end
    _annotation =
      match annotation'
      | let an: NodeWith[Annotation] => an
      else orig._annotation
      end
    _doc_strings =
      match doc_strings'
      | let ds: NodeSeqWith[DocString] => ds
      else orig._doc_strings
      end
    _pre_trivia =
      match pre_trivia'
      | let pt: NodeSeqWith[Trivia] => pt
      else orig._pre_trivia
      end
    _post_trivia =
      match post_trivia'
      | let pt: NodeSeqWith[Trivia] => pt
      else orig._post_trivia
      end
    _error_sections =
      match error_sections'
      | let es: NodeSeqWith[ErrorSection] => es
      else orig._error_sections
      end
    _ast_type =
      match ast_type'
      | let at: types.AstType => at
      else orig._ast_type
      end

  fun val clone(
    src_info': (SrcInfo | None) = None,
    new_children': (NodeSeq | None) = None,
    update_map': (ChildUpdateMap | None) = None,
    annotation': (NodeWith[Annotation] | None) = None,
    doc_strings': (NodeSeqWith[DocString] | None) = None,
    pre_trivia': (NodeSeqWith[Trivia] | None) = None,
    post_trivia': (NodeSeqWith[Trivia] | None) = None,
    error_sections': (NodeSeqWith[ErrorSection] | None) = None,
    ast_type': (types.AstType | None) = None): Node
  =>
    let data'' =
      match update_map'
      | let um: ChildUpdateMap =>
        try _data.clone(um) as D else _data end
      else
        _data
      end
    let annotation'' =
      match annotation'
      | let a: NodeWith[Annotation] =>
        a
      else
        match (_annotation, update_map')
        | (let a: NodeWith[Annotation], let um: ChildUpdateMap) =>
          try um(a)? as NodeWith[Annotation] else _annotation end
        else
          _annotation
        end
      end
    let doc_strings'' =
      match doc_strings'
      | let ds: NodeSeqWith[DocString] =>
        ds
      else
        match update_map'
        | let um: ChildUpdateMap =>
          map[DocString](_doc_strings, um)
        else
          _doc_strings
        end
      end
    let pre_trivia'' =
      match pre_trivia'
      | let pt: NodeSeqWith[Trivia] =>
        pt
      else
        match update_map'
        | let um: ChildUpdateMap =>
          map[Trivia](_pre_trivia, um)
        else
          _pre_trivia
        end
      end
    let post_trivia'' =
      match post_trivia'
      | let pt: NodeSeqWith[Trivia] =>
        pt
      else
        match update_map'
        | let um: ChildUpdateMap =>
          map[Trivia](_post_trivia, um)
        else
          _post_trivia
        end
      end
    let error_sections'' =
      match error_sections'
      | let es: NodeSeqWith[ErrorSection] =>
        es
      else
        match update_map'
        | let um: ChildUpdateMap =>
          map[ErrorSection](_error_sections, um)
        else
          _error_sections
        end
      end

    NodeWith[D].from(
      this,
      src_info',
      new_children',
      data'',
      annotation'',
      doc_strings'',
      pre_trivia'',
      post_trivia'',
      error_sections'',
      ast_type')

  fun val name(): String =>
    """The kind of data that is stored in this node."""
    _data.name()

  fun val src_info(): SrcInfo =>
    """Source file information for this node."""
    _src_info

  fun val children(): NodeSeq =>
    """The complete list of children of this node."""
    _children

  fun val data(): D =>
    """
      Semantic data associated with this node.  Node references in `data` must
      reference nodes in `children`.
    """
    _data

  fun val doc_strings(): NodeSeqWith[DocString] =>
    """
      Zero or more doc strings associated with this node.  Must be references
      to nodes in `children`.
    """
    _doc_strings

  fun val annotation(): (NodeWith[Annotation] | None) =>
    """
      The node's annotation, if any. Must be a reference to a node in
      `children`.
    """
    _annotation

  fun val pre_trivia(): NodeSeqWith[Trivia] =>
    """
      Trivia (whitespace, comments) that appears before the significant content
      of this node. Likely only appears in `SrcFile`. Must be references to
      nodes in `children`.
    """
    _pre_trivia

  fun val post_trivia(): NodeSeqWith[Trivia] =>
    """
      Trivia (whitespace, comments) that appears after the significant content
      of this node. Must be references to nodes in `children`.
    """
    _post_trivia

  fun val error_sections(): NodeSeqWith[ErrorSection] =>
    """
      Any error sections that appear in `children`.
    """
    _error_sections

  fun val ast_type(): (types.AstType | None) =>
    """The resolved type of this node, if any."""
    _ast_type

  fun val get_json()
    : json.Object
  =>
    """Get a JSON representation of the node."""
    let props = [ as (String, json.Item): ("name", name()) ]
    match (_src_info.line, _src_info.column)
    | (let line: USize, let column: USize) =>
      let si = json.Object(
        [ as (String, json.Item):
          ("line", I128.from[USize](line))
          ("column", I128.from[USize](column))])
      props.push(("src_info", si))
    end
    match _annotation
    | let annotation': NodeWith[Annotation] =>
      props.push(("annotation", child_ref(annotation')))
    end
    _data.add_json_props(this, props)
    if _error_sections.size() > 0 then
      props.push(("error_sections", child_refs(_error_sections)))
    end
    if _doc_strings.size() > 0 then
      props.push(("doc_strings", child_refs(_doc_strings)))
    end
    if _pre_trivia.size() > 0 then
      props.push(("pre_trivia", child_refs(_pre_trivia)))
    end
    if _post_trivia.size() > 0 then
      props.push(("post_trivia", child_refs(_post_trivia)))
    end
    if _children.size() > 0 then
      let child_json = json.Sequence.from_iter(
        Iter[Node](_children.values()).map[json.Item](
          {(child) => child.get_json()}))
      props.push(("children", child_json))
    end
    json.Object(props)

  fun val string(): String iso^ =>
    this.get_json().string()

type NodeSeqWith[D: NodeData val] is ReadSeq[NodeWith[D]] val
  """A sequence of AST nodes with a given node data type."""
