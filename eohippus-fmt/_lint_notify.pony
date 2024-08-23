use "files"

use ast = "../eohippus/ast"
use linter = "../eohippus/linter"
use parser = "../eohippus/parser"

actor _LintNotify is linter.LinterNotify
  let _env: Env
  let _options: _CliOptions
  let _path: String
  let _buf: String ref

  new create(env: Env, options: _CliOptions, path: String) =>
    _env = env
    _options = options
    _path = path
    _buf = String

  be lint_completed(
    lint: linter.Linter,
    task_id: USize,
    tree: ast.Node,
    issues: ReadSeq[linter.Issue] val,
    errors: ReadSeq[ast.TraverseError] val)
  =>
    _print_traverse_errors(errors)
    if _options.verbose then
      _print_lint_issues(issues)
    end

    if errors.size() == 0 then
      lint.fix(0, tree, issues)
    end

  be fix_completed(
    lint: linter.Linter,
    task_id: USize,
    tree: ast.Node,
    issues: ReadSeq[linter.Issue] val,
    errors: ReadSeq[ast.TraverseError] val)
  =>
    _print_traverse_errors(errors)
    _print_lint_issues(issues)
    if (errors.size() == 0) and (issues.size() == 0) then
      match CreateFile(FilePath(FileAuth(_env.root), _path))
      | let file: File =>
        if _options.verbose then
          _env.err.print("Overwriting " + _path)
        end

        file.set_length(0)
        _write_pony_file(tree, file)
        file.dispose()
      else
        _env.err.print("Unable to write to " + _path)
      end
    else
      _env.err.print("Errors found; not modifying " + _path)
    end

  fun ref _write_pony_file(node: ast.Node, file: File) =>
    if node.children().size() == 0 then
      let si = node.src_info()
      match (si.start, si.next)
      | (let start': parser.Loc, let next': parser.Loc) =>
        _buf.clear()
        _buf.concat(start'.values(next'))
        file.write(_buf)
      end
    else
      for child in node.children().values() do
        _write_pony_file(child, file)
      end
    end

  fun _print_traverse_errors(errors: ReadSeq[ast.TraverseError] val) =>
    for (node, message) in errors.values() do
      let si = node.src_info()
      (let line_no: String, let col_no: String) =
        match (si.line, si.column)
        | (let l: USize, let c: USize) =>
          ((l + 1).string(), (c + 1).string())
        else
          ("?", "?")
        end
      _env.err.print(_path + ":" + line_no + ":" + col_no + ": " + message)
    end

  fun _print_lint_issues(issues: ReadSeq[linter.Issue] val) =>
    for issue in issues.values() do
      (let line_no: String, let col_no: String) =
        try
          let si = issue.start.head()?.src_info()
          match (si.line, si.column)
          | (let l: USize, let c: USize) =>
            ((l + 1).string(), (c + 1).string())
          else
            error
          end
        else
          ("?", "?")
        end
      _env.err.print(
        _path + ":" + line_no + ":" + col_no + ": " + issue.rule.message())
    end
