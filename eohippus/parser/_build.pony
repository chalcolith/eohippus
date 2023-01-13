use "itertools"

use ast = "../ast"
use ".."

primitive _Build
  fun info(success: Success): ast.SrcInfo =>
    ast.SrcInfo(success.data.locator(), success.start, success.next)

  fun docstrings(b: Bindings, ds: Variable): ast.NodeSeq[ast.Docstring] =>
    recover val
      try
        Array[ast.Docstring].>concat(
          Iter[ast.Node](b(ds)?._2.values())
            .filter_map[ast.Docstring](
              {(node: ast.Node): (ast.Docstring | None) =>
                try node as ast.Docstring end
              }))
      else
        Array[ast.Docstring]
      end
    end

  fun result(b: Bindings, v: Variable): Success? =>
    b(v)?._1

  fun value(b: Bindings, v: Variable): ast.Node? =>
    b(v)?._2(0)?

  fun value_or_none(b: Bindings, v: Variable): (ast.Node | None) =>
    try
      b(v)?._2(0)?
    end

  fun values(b: Bindings, v: Variable): ast.NodeSeq[ast.Node]? =>
    b(v)?._2

  fun with_post[T: ast.Node val](
    body: RuleNode,
    post: RuleNode,
    action: {(Success, ast.NodeSeq[ast.Node], Bindings, T)
      : ((ast.Node | None), Bindings)} val)
    : RuleNode ref
  =>
    let p = Variable("p")
    Conj(
      [
        body
        Bind(p, post)
      ],
      {(r, c, b) =>
        let t =
          try
            _Build.value(b, p)? as T
          else
            return _Build.bind_error(r, c, b, "post")
          end
        action(r, c, b, t)
      }
    )

  fun bind_error(r: Success, c: ast.NodeSeq[ast.Node], b: Bindings,
    message: String): (ast.Node, Bindings)
  =>
    (ast.ErrorSection(_Build.info(r), c,
      ErrorMsg.internal_ast_node_not_bound(message)), b)
