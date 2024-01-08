use "itertools"

use ast = "../ast"
use ".."

primitive _Build
  fun info(data: Data, success: Success): ast.SrcInfo =>
    ast.SrcInfo(data.locator, success.start, success.next)

  fun result(b: Bindings, v: Variable, r: Success): Success ? =>
    b.result(v, r)?

  fun value(b: Bindings, v: Variable, r: Success): ast.Node ? =>
    b.values(v, r)?(0)?

  fun value_or_none(b: Bindings, v: Variable, r: Success): (ast.Node | None) =>
    try b.values(v, r)?(0)? end

  fun value_with[D: ast.NodeData val](b: Bindings, v: Variable, r: Success)
    : ast.NodeWith[D] ?
  =>
    b.values(v, r)?(0)? as ast.NodeWith[D]

  fun value_with_or_none[D: ast.NodeData val](
    b: Bindings,
    v: Variable,
    r: Success)
    : (ast.NodeWith[D] | None)
  =>
    try b.values(v, r)?(0)? as ast.NodeWith[D] end

  fun values(b: Bindings, v: Variable, r: Success) : ast.NodeSeq =>
    try
      b.values(v, r)?
    else
      []
    end

  fun values_with[D: ast.NodeData val](b: Bindings, v: Variable, r: Success)
    : ast.NodeSeqWith[D]
  =>
    try
      let vs = b.values(v, r)?

      for n in vs.values() do
        let str = n.get_json().string()
        str.clear()
      end

      nodes_with[D](vs)
    else
      []
    end

  fun nodes_with[D: ast.NodeData val](c: ast.NodeSeq)
    : ast.NodeSeqWith[D]
  =>
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
    let p = Variable("p")
    Conj(
      [ body; Bind(p, Ques(post)) ],
      {(d, r, c, b) =>
        action(d, r, c, b, _Build.values_with[D](b, p, r))
      })

  fun span_and_post(si: ast.SrcInfo, c: ast.NodeSeq, p: ast.NodeSeq)
    : ast.NodeSeq
  =>
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
    let message' = ErrorMsg.internal_ast_node_not_bound(message)
    let value' = ast.NodeWith[ast.ErrorSection](
      _Build.info(d, r), c, ast.ErrorSection(message'))
    (value', b)
