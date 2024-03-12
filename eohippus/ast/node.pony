"""
  This package provides an abstract syntax tree for Pony code.

  The AST is built from [NodeWith](/eohippus/eohippus-ast-NodeWith) objects that contain semantic information about their children.

  A Pony source file is represented by a node with [SrcFile](/eohippus/eohippus-ast-SrcFile/) data.
"""

use "collections"
use "itertools"

use json = "../json"
use types = "../types"

trait val Node
  """An AST node."""

  fun val clone(
    src_info': (SrcInfo | None) = None,
    old_children': (NodeSeq | None) = None,
    new_children': (NodeSeq | None) = None,
    data': (NodeData | None) = None,
    annotation': (NodeWith[Annotation] | None) = None,
    doc_strings': (NodeSeqWith[DocString] | None) = None,
    pre_trivia': (NodeSeqWith[Trivia] | None) = None,
    post_trivia': (NodeSeqWith[Trivia] | None) = None,
    error_sections': (NodeSeqWith[ErrorSection] | None) = None,
    ast_type': (types.AstType | None) = None): Node ?
    """
      Used to clone the node with certain updated properties during AST
      transformation.
    """

  fun name(): String
    """An informative identifier for the kind of data the node stores."""

  fun src_info(): SrcInfo
    """Source location information."""

  fun children(): NodeSeq

  fun annotation(): (NodeWith[Annotation] | None)

  fun doc_strings(): NodeSeqWith[DocString]

  fun pre_trivia(): NodeSeqWith[Trivia]

  fun post_trivia(): NodeSeqWith[Trivia]

  fun error_sections(): NodeSeqWith[ErrorSection]

  fun ast_type(): (types.AstType | None)
    """The resolved type of the node."""

  fun fix_up[T: NodeData val](anciliary: NodeSeqWith[T], new_children: NodeSeq)
    : (NodeSeqWith[T] | None)
  =>
    """
      Assuming `new_children` is the result of pruning, returns a new anciliary
      list containing only those anciliary nodes that appear in `new_children`.
    """
    var result: (Array[NodeWith[T]] trn | None) = None
    var i: USize = 0 // current position in anciliary
    var c: USize = 0 // start position in children
    while i < anciliary.size() do
      var j: USize = c
      while j < new_children.size() do
        try
          if anciliary(i)? is new_children(j)? then
            if result is None then
              result = recover trn Array[NodeWith[T]] end
            end
            match result
            | let result': Array[NodeWith[T]] trn =>
              result'.push(anciliary(i)?)
            end
            c = j + 1
            break
          end
        end
        j = j + 1
      end
      i = i + 1
    end
    consume result

  fun get_json(lines_and_columns: (LineColumnMap | None) = None)
    : json.Item
    """Get a semantic JSON representation of the node."""

  fun get_child_json(lines_and_columns: (LineColumnMap | None) = None)
    : json.Item
    """Get a JSON representation of the node without semantic properties."""

  fun string(): String iso^

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
                (t.data().kind is EndOfFileTrivia) or
                (t.src_info().start < t.src_info().next)
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
          .any({(n) => n.src_info().start < n.src_info().next })
      then
        doc_strings'
      else
        []
      end
    _pre_trivia =
      if (pre_trivia'.size() == 0) or
        Iter[NodeWith[Trivia]](pre_trivia'.values())
          .any({(n) =>
            (n.data().kind is EndOfFileTrivia) or
            (n.src_info().start < n.src_info().next) })
      then
        pre_trivia'
      else
        []
      end
    _post_trivia =
      if (post_trivia'.size() == 0) or
        Iter[NodeWith[Trivia]](post_trivia'.values())
          .any({(n) =>
            (n.data().kind is EndOfFileTrivia) or
            (n.src_info().start < n.src_info().next) })
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

  new val from(
    orig: NodeWith[D],
    src_info': (SrcInfo | None) = None,
    children': (NodeSeq | None) = None,
    data': (NodeData | None) = None,
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
    old_children': (NodeSeq | None) = None,
    new_children': (NodeSeq | None) = None,
    data': (NodeData | None) = None,
    annotation': (NodeWith[Annotation] | None) = None,
    doc_strings': (NodeSeqWith[DocString] | None) = None,
    pre_trivia': (NodeSeqWith[Trivia] | None) = None,
    post_trivia': (NodeSeqWith[Trivia] | None) = None,
    error_sections': (NodeSeqWith[ErrorSection] | None) = None,
    ast_type': (types.AstType | None) = None): Node ?
  =>
    let data'' =
      match data'
      | let d: NodeData =>
        d as D
      else
        match (old_children', new_children')
        | (let oc: NodeSeq, let nc: NodeSeq) =>
          _data.clone(oc, nc)? as D
        end
      end
    let annotation'' =
      match annotation'
      | let a: NodeWith[Annotation] =>
        a
      else
        match (old_children', new_children')
        | (let oc: NodeSeq, let nc: NodeSeq) =>
          NodeChild.with_or_none[Annotation](_annotation, oc, nc)?
        end
      end
    let doc_strings'' =
      match doc_strings'
      | let ds: NodeSeqWith[DocString] =>
        ds
      else
        match (old_children', new_children')
        | (let oc: NodeSeq, let nc: NodeSeq) =>
          NodeChild.seq_with[DocString](_doc_strings, oc, nc)?
        end
      end
    let pre_trivia'' =
      match pre_trivia'
      | let pt: NodeSeqWith[Trivia] =>
        pt
      else
        match (old_children', new_children')
        | (let oc: NodeSeq, let nc: NodeSeq) =>
          NodeChild.seq_with[Trivia](_pre_trivia, oc, nc)?
        end
      end
    let post_trivia'' =
      match post_trivia'
      | let pt: NodeSeqWith[Trivia] =>
        pt
      else
        match (old_children', new_children')
        | (let oc: NodeSeq, let nc: NodeSeq) =>
          NodeChild.seq_with[Trivia](_post_trivia, oc, nc)?
        end
      end
    let error_sections'' =
      match error_sections'
      | let es: NodeSeqWith[ErrorSection] =>
        es
      else
        match (old_children', new_children')
        | (let oc: NodeSeq, let nc: NodeSeq) =>
          NodeChild.seq_with[ErrorSection](_error_sections, oc, nc)?
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

  fun name(): String =>
    """The kind of data that is stored in this node."""
    _data.name()

  fun src_info(): SrcInfo =>
    """Source file information for this node."""
    _src_info

  fun children(): NodeSeq =>
    """The complete list of children of this node."""
    _children

  fun data(): D =>
    """
      Semantic data associated with this node.  Node references in `data` must
      reference nodes in `children`.
    """
    _data

  fun doc_strings(): NodeSeqWith[DocString] =>
    """
      Zero or more doc strings associated with this node.  Must be references
      to nodes in `children`.
    """
    _doc_strings

  fun annotation(): (NodeWith[Annotation] | None) =>
    """
      The node's annotation, if any. Must be a reference to a node in
      `children`.
    """
    _annotation

  fun pre_trivia(): NodeSeqWith[Trivia] =>
    """
      Trivia (whitespace, comments) that appears before the significant content
      of this node. Likely only appears in `SrcFile`. Must be references to
      nodes in `children`.
    """
    _pre_trivia

  fun post_trivia(): NodeSeqWith[Trivia] =>
    """
      Trivia (whitespace, comments) that appears after the significant content
      of this node. Must be references to nodes in `children`.
    """
    _post_trivia

  fun error_sections(): NodeSeqWith[ErrorSection] =>
    """
      Any error sections that appear in `children`.
    """
    _error_sections

  fun ast_type(): (types.AstType | None) =>
    """The resolved type of this node, if any."""
    _ast_type

  fun get_json(lines_and_columns: (LineColumnMap | None) = None)
    : json.Item
  =>
    """Get a JSON representation of the semantics of this node and its data."""
    let props = [ as (String, json.Item): ("name", name()) ]
    match lines_and_columns
    | let lc: LineColumnMap =>
      try
        (let line, let column) = lc(this)?
        let si = json.Object(
          [ as (String, json.Item):
            ("line", I128.from[USize](line))
            ("column", I128.from[USize](column))])
        props.push(("src_info", si))
      end
    end
    match _annotation
    | let annotation': NodeWith[Annotation] =>
      props.push(("annotation", annotation'.get_json(lines_and_columns)))
    end
    _data.add_json_props(props, lines_and_columns)
    if _error_sections.size() > 0 then
      props.push(
        ("error_sections", Nodes.get_json(_error_sections, lines_and_columns)))
    end
    if _pre_trivia.size() > 0 then
      props.push(
        ("pre_trivia", Nodes.get_json(_pre_trivia, lines_and_columns)))
    end
    if _doc_strings.size() > 0 then
      props.push(
        ("doc_strings", Nodes.get_json(_doc_strings, lines_and_columns)))
    end
    if _post_trivia.size() > 0 then
      props.push(
        ("post_trivia", Nodes.get_json(_post_trivia, lines_and_columns)))
    end
    json.Object(props)

  fun get_child_json(lines_and_columns: (LineColumnMap | None) = None)
    : json.Item
  =>
    """
      Get a JSON representation of this node (without semantic data) and its
      children.
    """
    let props = [ as (String, json.Item): ("name", name()) ]
    match lines_and_columns
    | let lc: LineColumnMap =>
      try
        (let line, let column) = lc(this)?
        let si = json.Object(
          [ as (String, json.Item):
            ("line", I128.from[USize](line))
            ("column", I128.from[USize](column))])
        props.push(("src_info", si))
      end
    end
    if _children.size() > 0 then
      let child_json = json.Sequence.from_iter(
        Iter[Node](_children.values()).map[json.Item](
          {(child) => child.get_child_json(lines_and_columns)}))
      props.push(("children", child_json))
    end
    json.Object(props)

  fun string(): String iso^ =>
    this.get_json().string()

type NodeSeq is ReadSeq[Node] val
  """A sequence of AST nodes."""

type NodeSeqWith[D: NodeData val] is ReadSeq[NodeWith[D]] val
  """A sequence of AST nodes with a given node data type."""
