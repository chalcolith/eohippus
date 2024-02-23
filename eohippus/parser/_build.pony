use "itertools"

use ast = "../ast"
use ".."

primitive _Build
  """Contains utilities for building the parser."""

  fun info(data: Data, success: Success): ast.SrcInfo =>
    """Returns source info from a parse result."""
    ast.SrcInfo(data.locator, success.start, success.next)

  fun result(b: Bindings, v: Variable, r: Success): Success ? =>
    """
      Returns the "result", if any, bound to a variable in the scope of the
      given result.
    """
    b.result(v, r)?

  fun value(b: Bindings, v: Variable, r: Success): ast.Node ? =>
    """
      Returns the first computed "value", if any, bound to a variable in the
      scope of the given result.
    """
    b.values(v, r)?(0)?

  fun value_or_none(b: Bindings, v: Variable, r: Success): (ast.Node | None) =>
    """
      Returns the first computed "value", if any, bound to a variable in the
      scope of the given result.
    """
    try b.values(v, r)?(0)? end

  fun value_with[D: ast.NodeData val](b: Bindings, v: Variable, r: Success)
    : ast.NodeWith[D] ?
  =>
    """
      Returns the first computed "value" of the given type, if any, bound to the
      variable in the scope of the given result.
    """
    b.values(v, r)?(0)? as ast.NodeWith[D]

  fun value_with_or_none[D: ast.NodeData val](
    b: Bindings,
    v: Variable,
    r: Success)
    : (ast.NodeWith[D] | None)
  =>
    """
      Returns the first computed "value" of the given type, if any, bound to the
      variable in the scope of the given result.
    """
    try b.values(v, r)?(0)? as ast.NodeWith[D] end

  fun values(b: Bindings, v: Variable, r: Success) : ast.NodeSeq =>
    """
      Returns the sequence of computed "values" bound to a variable in the scope
      of the given result.
    """
    try
      b.values(v, r)?
    else
      []
    end

  fun values_with[D: ast.NodeData val](b: Bindings, v: Variable, r: Success)
    : ast.NodeSeqWith[D]
  =>
    """
      Returns the sequence of computed "values" of a given type bound to a
      variable in the scope of the given result.
    """
    try
      nodes_with[D](b.values(v, r)?)
    else
      []
    end

  fun nodes_with[D: ast.NodeData val](c: ast.NodeSeq)
    : ast.NodeSeqWith[D]
  =>
    """
      Returns a sequence of nodes of a given type present in the original
      sequence.
    """
    recover val
      Array[ast.NodeWith[D]](c.size()) .> concat(
        Iter[ast.Node](c.values())
          .filter_map[ast.NodeWith[D]](
            {(n) => try n as ast.NodeWith[D] end }))
    end

  fun values_and_errors[D: ast.NodeData val](
    b: Bindings,
    v: Variable,
    r: Success,
    e: Array[ast.NodeWith[ast.ErrorSection]] ref)
    : ast.NodeSeqWith[D]
  =>
    """
      Returns the computed "values" bound to a variable, as well as collecting
      any error sections in the variable's node.
    """
    let rvals: Array[ast.NodeWith[D]] trn = Array[ast.NodeWith[D]]()
    try
      let vvals = b.values(v, r)?
      for vval in vvals.values() do
        match vval
        | let node: ast.NodeWith[D] =>
          rvals.push(node)
        | let err: ast.NodeWith[ast.ErrorSection] =>
          e.push(err)
        end
      end
    end
    consume rvals

  fun with_post[D: ast.NodeData val](
    body: RuleNode box,
    post: RuleNode box,
    action:
      {(Data, Success, ast.NodeSeq, Bindings, ast.NodeSeqWith[D])
        : ((ast.Node | None), Bindings)} val)
    : RuleNode
  =>
    """
      Builds a parser combinator that matches `body` followed by `post`, and
      computes a value using `action`.
    """
    let p = Variable("p")
    Conj(
      [ body; Bind(p, Ques(post)) ],
      {(d, r, c, b) =>
        action(d, r, c, b, _Build.values_with[D](b, p, r))
      })

  fun span_and_post(si: ast.SrcInfo, c: ast.NodeSeq, p: ast.NodeSeq)
    : ast.NodeSeq
  =>
    """
      Constructs a span plus post-trivia from a given node.
    """
    let next =
      try
        p(0)?.src_info().start
      else
        si.next
      end
    let span = ast.NodeWith[ast.Span](
      ast.SrcInfo(si.locator, si.start, next), [], ast.Span)
    recover val [as ast.Node: span] .> concat(c.values()) end

  fun bind_error(d: Data, r: Success, c: ast.NodeSeq, b: Bindings,
    message: String): (ast.Node, Bindings)
  =>
    """
      Constructs an error section with an error message relating to the
      inability to get the results or values from a variable that should
      have been bound but was not.  This should never happen.
    """
    let message' = ErrorMsg.internal_ast_node_not_bound(message)
    let value' = ast.NodeWith[ast.ErrorSection](
      _Build.info(d, r), c, ast.ErrorSection(message'))
    (value', b)
