"""
  This package provides an abstract syntax tree for Pony code.

  The AST is built from [NodeWith](/eohippus/eohippus-ast-NodeWith) objects that contain semantic information about their children.

  A Pony source file is represented by a node with [SrcFile](/eohippus/eohippus-ast-SrcFile/) data.
"""

use "collections"
use "itertools"

use json = "../json"
use parser = "../parser"
use types = "../types"

trait val Node
  """An AST node."""

  fun val clone(
    src_info': (SrcInfo | None) = None,
    new_children': (NodeSeq | None) = None,
    update_map': (ChildUpdateMap | None) = None,
    annotation': (NodeWith[Annotation] | None) = None,
    doc_strings': (NodeSeqWith[DocString] | None) = None,
    pre_trivia': (NodeSeqWith[Trivia] | None) = None,
    post_trivia': (NodeSeqWith[Trivia] | None) = None,
    ast_type': (types.AstType | None) = None,
    scope_index': (USize | None) = None): Node
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

  fun ast_type(): (types.AstType | None)
    """The resolved type of the node."""

  fun scope_index(): (USize | None)

  fun get_json() : json.Object
    """Get a JSON representation of the node."""

  fun map[D: NodeData val](seq: NodeSeqWith[D], updates: ChildUpdateMap)
    : NodeSeqWith[D]
  =>
    let result: Array[NodeWith[D]] trn = Array[NodeWith[D]](seq.size())
    for node in seq.values() do
      try
        result.push(updates(node)? as NodeWith[D])
      end
    end
    consume result

  fun child_ref(child: Node): json.Item =>
    var i: USize = 0
    while i < children().size() do
      try
        if child is children()(i)? then
          return I128.from[USize](i)
        end
      end
      i = i + 1
    end
    I128.from[ISize](-1)

  fun child_refs(childs: NodeSeq): json.Item =>
    let seq = Array[json.Item](childs.size())
    for child in childs.values() do
      seq.push(child_ref(child))
    end
    json.Sequence(seq)

  fun string(): String iso^

type NodeSeq is ReadSeq[Node] val
  """A sequence of AST nodes."""
