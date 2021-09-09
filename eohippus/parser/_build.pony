use ast = "../ast"

primitive _Build
  fun info(success: Success): ast.SrcInfo =>
    ast.SrcInfo(success.data.locator(), success.start, success.next)
