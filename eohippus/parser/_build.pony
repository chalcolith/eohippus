use "itertools"

use ast = "../ast"

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

  fun value(b: Bindings, v: Variable): ast.Node? =>
    b(v)?._2(0)?

  fun values(b: Bindings, v: Variable): ast.NodeSeq[ast.Node]? =>
    b(v)?._2
