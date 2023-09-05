use "itertools"

use ast = "../ast"
use ".."

primitive _Build
  fun info(success: Success): ast.SrcInfo =>
    ast.SrcInfo(success.data.locator, success.start, success.next)

  fun result(b: Bindings, v: Variable, r: Success): Success ? =>
    b.result(v, r)?

  fun value(b: Bindings, v: Variable, r: Success): ast.Node ? =>
    b.values(v, r)?(0)?

  fun value_or_none(b: Bindings, v: Variable, r: Success): (ast.Node | None) =>
    try b.values(v, r)?(0)? end

  fun value_with[N: ast.NodeData val](b: Bindings, v: Variable, r: Success)
    : ast.NodeWith[N] ?
  =>
    b.values(v, r)?(0)? as ast.NodeWith[N]

  fun value_with_or_none[N: ast.NodeData val](
    b: Bindings,
    v: Variable,
    r: Success)
    : (ast.NodeWith[N] | None)
  =>
    try b.values(v, r)?(0)? as ast.NodeWith[N] end

  fun values(b: Bindings, v: Variable, r: Success) : ast.NodeSeq =>
    try
      b.values(v, r)?
    else
      []
    end

  fun values_with[N: ast.NodeData val](b: Bindings, v: Variable, r: Success)
    : ast.NodeSeqWith[N]
  =>
    try
      let vs = b.values(v, r)?

      for n in vs.values() do
        let str = n.get_json().string()
        str.clear()
      end

      nodes_with[N](vs)
    else
      []
    end

  fun nodes_with[N: ast.NodeData val](c: ast.NodeSeq)
    : ast.NodeSeqWith[N]
  =>
    recover val
      Array[ast.NodeWith[N]](c.size()) .> concat(
        Iter[ast.Node](c.values())
          .filter_map[ast.NodeWith[N]](
            {(n) => try n as ast.NodeWith[N] end }))
    end

  fun values_and_errors[N: ast.NodeData val](
    b: Bindings,
    v: Variable,
    r: Success,
    e: Array[ast.NodeWith[ast.ErrorSection]] ref)
    : ast.NodeSeqWith[N]
  =>
    let rvals: Array[ast.NodeWith[N]] trn = Array[ast.NodeWith[N]]()
    try
      let vvals = b.values(v, r)?
      for vval in vvals.values() do
        match vval
        | let node: ast.NodeWith[N] =>
          rvals.push(node)
        | let err: ast.NodeWith[ast.ErrorSection] =>
          e.push(err)
        end
      end
    end
    consume rvals

  fun with_post[T: ast.NodeData val](
    body: RuleNode,
    post: RuleNode,
    action:
      {(Success, ast.NodeSeq, Bindings, ast.NodeSeqWith[T])
        : ((ast.Node | None), Bindings)} val)
    : RuleNode ref
  =>
    let p = Variable("p")
    Conj(
      [ body; Bind(p, Ques(post)) ],
      {(r, c, b) =>
        action(r, c, b, _Build.values_with[T](b, p, r))
      })

  fun bind_error(r: Success, c: ast.NodeSeq, b: Bindings,
    message: String): (ast.Node, Bindings)
  =>
    let message' = ErrorMsg.internal_ast_node_not_bound(message)
    let value' = ast.NodeWith[ast.ErrorSection](
      _Build.info(r), c, ast.ErrorSection(message'))
    (value', b)
