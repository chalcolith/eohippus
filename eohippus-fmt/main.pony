use "files"

use ast = "../eohippus/ast"
use linter = "../eohippus/linter"
use parser = "../eohippus/parser"
use types = "../eohippus/types"

actor Main
  let _pony_ext: String = ".pony"

  let _env: Env
  var _lint_config: linter.Config val
  let _options: _CliOptions
  var _next_task_id: USize = 0

  new create(env: Env) =>
    _env = env
    _lint_config = linter.EditorConfig.default()
    var good_options = true
    _options =
      try
        _BuildCliOptions(_env)?
      else
        good_options = false
        _CliOptions.default()
      end
    if good_options then
      _start_processing()
    end

  be _start_processing() =>
    let target_file_path = FilePath(FileAuth(_env.root), _options.target_path)
    try
      let target_info = FileInfo(target_file_path)?
      match _find_editor_config(Path.split(target_file_path.path)._1)
      | let config: linter.Config val =>
        _lint_config = config
      end

      if target_info.directory then
        target_info.filepath.walk(this~_process_directory())
      else
        _process_file(_next_task_id, target_info.filepath.path)
      end
    else
      _env.err.print("Unable to open " + _options.target_path)
      _env.exitcode(2)
    end

  fun _find_editor_config(dname: String): (linter.Config val | None) =>
    let config: linter.Config trn = linter.Config
    var cur_dname = dname
    while cur_dname.size() > 0 do
      let ec_path = FilePath(
        FileAuth(_env.root), Path.join(cur_dname, ".editorconfig"))
      if ec_path.exists() then
        match linter.EditorConfig.read(ec_path)
        | let cur_config: linter.Config val =>
          for (key, value) in cur_config.pairs() do
            config.insert_if_absent(key, value)
          end
        | let error_message: String =>
          if _options.verbose then
            _env.err.print(error_message)
          end
        end
      end
      cur_dname = Path.split(cur_dname)._1
    end
    if config.size() > 0 then
      consume config
    else
      None
    end

  fun _is_pony_file(fname: String): Bool =>
    let ext_size = _pony_ext.size()
    if fname.size() <= ext_size then
      return false
    end
    let index = ISize.from[USize](fname.size() - ext_size)
    fname.compare_sub(
      _pony_ext, ext_size, index where ignore_case = true) is Equal

  fun ref _process_directory(dir_path: FilePath, entries: Array[String]) =>
    for entry in entries.values() do
      if _is_pony_file(entry) then
        _process_file(_next_task_id, Path.join(dir_path.path, entry))
        _next_task_id = _next_task_id + 1
      end
    end

  be _process_file(task_id: USize, fname: String) =>
    let file_path = FilePath(FileAuth(_env.root), fname)
    if _options.verbose then
      _env.err.print(file_path.path)
    end
    match OpenFile(file_path)
    | let file: File =>
      let bytes = file.read(file.size())
      if bytes.size() != file.size() then
        _env.err.print("Error reading " + file_path.path)
        return
      end

      let lint_notify = _LintNotify(_env, _options, file_path.path)
      let lint = linter.Linter(_lint_config, lint_notify)

      let parse = parser.Parser([ consume bytes ])
      let parse_data = parser.Data(file_path.path)
      let grammar_context = parser.Context(Array[types.AstPackage val])
      let grammar_builder = recover val parser.Builder(grammar_context) end
      let grammar_rule = grammar_builder.src_file.src_file
      let self: Main tag = this
      let env = _env
      parse.parse(
        grammar_rule,
        parse_data,
        { (r: parser.Result, nodes: ast.NodeSeq) =>
          match r
          | let success: parser.Success =>
            let root =
              try
                nodes(0)? as ast.NodeWith[ast.SrcFile]
              else
                env.err.print(
                  file_path.path + ": internal error parsing; no root SrcFile")
                return
              end

            (let root_with_line_info, _, _) = ast.SyntaxTree.add_line_info(root)
            self._print_error_sections(env, file_path.path, root_with_line_info)

            lint.lint(task_id, root_with_line_info)
          | let failure: parser.Failure =>
            env.err.print(
              file_path.path + ": parse failed: " + failure.get_message())
          end
        })
    else
      _env.err.print("Unable to open " + file_path.path)
    end

  fun tag _print_error_sections(env: Env, path: String, node: ast.Node) =>
    match node
    | let es: ast.NodeWith[ast.ErrorSection] =>
      let si = es.src_info()
      match (si.line, si.column)
      | (let l: USize, let c: USize) =>
        env.err.print(
          path + ":" + (l + 1).string() + ":" + (c + 1).string() + ": " +
          es.data().message)
      else
        env.err.print(path + ":?:?: " + es.data().message)
      end
    else
      for child in node.children().values() do
        _print_error_sections(env, path, child)
      end
    end
