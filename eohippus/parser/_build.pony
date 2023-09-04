use "itertools"

use ast = "../ast"
use ".."

primitive _Build
  fun info(success: Success): ast.SrcInfo =>
    ast.SrcInfo(success.data.locator, success.start, success.next)

  fun result(b: Bindings, v: Variable): Success ? =>
    b(v)?._1

  fun value(b: Bindings, v: Variable): ast.Node ? =>
    b(v)?._2(0)?

  fun value_or_none(b: Bindings, v: Variable): (ast.Node | None) =>
    try b(v)?._2(0)? end

  fun value_with[N: ast.NodeData val](b: Bindings, v: Variable)
    : ast.NodeWith[N] ?
  =>
    b(v)?._2(0)? as ast.NodeWith[N]

  fun value_with_or_none[N: ast.NodeData val](
    b: Bindings,
    v: Variable)
    : (ast.NodeWith[N] | None)
  =>
    try b(v)?._2(0)? as ast.NodeWith[N] end

  fun values(b: Bindings, v: Variable) : ast.NodeSeq =>
    try
      b(v)?._2
    else
      []
    end

  fun values_with[N: ast.NodeData val](b: Bindings, v: Variable)
    : ast.NodeSeqWith[N]
  =>
    try
      let vs = b(v)?._2
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
    e: Array[ast.NodeWith[ast.ErrorSection]] ref)
    : ast.NodeSeqWith[N]
  =>
    let rvals: Array[ast.NodeWith[N]] trn = Array[ast.NodeWith[N]]()
    try
      let vvals = b(v)?._2
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
      {(r, c, b) => action(r, c, b, _Build.values_with[T](b, p)) })

  fun bind_error(r: Success, c: ast.NodeSeq, b: Bindings,
    message: String): (ast.Node, Bindings)
  =>
    let message' = ErrorMsg.internal_ast_node_not_bound(message)
    let value' = ast.NodeWith[ast.ErrorSection](
      _Build.info(r), c, ast.ErrorSection(message'))
    (value', b)
