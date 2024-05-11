use "collections"
use "files"
use "logger"
use "time"

use ast = "../ast"
use parser = "../parser"

interface tag Analyzer
  be open_file(task_id: USize, canonical_path: String, parse: parser.Parser)

  be update_file(task_id: USize, canonical_path: String, parse: parser.Parser)

  be close_file(task_id: USize, canonical_path: String)

  be dispose()

actor EohippusAnalyzer is Analyzer
  let _log: Logger[String]
  let _auth: FileAuth
  var _workspace: (FilePath | None)
  var _storage_path: (FilePath | None)
  var _pony_path: ReadSeq[FilePath]
  var _ponyc_executable: (FilePath | None)
  var _pony_packages_path: (FilePath | None)
  let _grammar: parser.NamedRule val
  let _notify: AnalyzerNotify

  let _src_files: Map[String, SrcFile] = _src_files.create()
  let _src_file_queue: List[SrcFile] = _src_file_queue.create()
  var _analysis_task_id: USize = 0
  var _analysis_in_progress: Bool = false

  let _workspace_errors: Array[AnalyzerError] = _workspace_errors.create()
  let _parse_errors: Array[AnalyzerError] = _parse_errors.create()
  let _lint_errors: Array[AnalyzerError] = _lint_errors.create()
  let _analyze_errors: Array[AnalyzerError] = _analyze_errors.create()

  var _disposing: Bool = false

  new create(
    log: Logger[String],
    auth: FileAuth,
    grammar: parser.NamedRule val,
    workspace: (FilePath | None),
    storage_path: (FilePath | None),
    pony_path: ReadSeq[FilePath] val,
    ponyc_executable: (FilePath | None),
    pony_packages_path: (FilePath | None),
    notify: AnalyzerNotify)
  =>
    _log = log
    _auth = auth
    _grammar = grammar
    _workspace = workspace
    _storage_path = storage_path
    _pony_path = pony_path
    _ponyc_executable = ponyc_executable
    _pony_packages_path = pony_packages_path
    _notify = notify

    match _workspace
    | let fp: FilePath =>
      let ws =
        match try fp.canonical()? end
        | let fp': FilePath =>
          _workspace = fp'
          fp'
        else
          fp
        end
      try
        let info = FileInfo(ws)?
        if not info.directory then
          _log(Error) and _log.log(fp.path + " is not a directory")
          _workspace_errors.push(AnalyzerError(
            ws.path, 0, 0, "workspace is not a directory"))
          _workspace = None
        end
      else
        _log(Error) and _log.log(fp.path + " does not exist")
        _workspace_errors.push(AnalyzerError(
          ws.path, 0, 0, "workspace directory does not exist"))
        _workspace = None
      end
    end
    match _workspace
    | let ws: FilePath =>
      _log(Fine) and _log.log("workspace is " + ws.path)
    else
      _log(Fine) and _log.log("workspace is None")
    end

    match _storage_path
    | let fp: FilePath =>
      let sp =
        match try fp.canonical()? end
        | let fp': FilePath =>
          _storage_path = fp'
          fp'
        else
          fp
        end
      try
        let info = FileInfo(sp)?
        if not info.directory then
          _log(Error) and _log.log(fp.path + " is not a directory")
          _workspace_errors.push(AnalyzerError(
            sp.path, 0, 0, "storage path is not a directory"))
          _storage_path = None
        end
      else
        _log(Error) and _log.log(fp.path + " unable to stat")
        _workspace_errors.push(AnalyzerError(
          sp.path, 0, 0, "unable to stat storage path"))
        _storage_path = None
      end
    else
      match _workspace
      | let fp: FilePath =>
        try
          let sp = fp.join(".eohippus")?
          if (not sp.exists() and not sp.mkdir()) then
            _log(Error) and _log.log("unable to create " + sp.path)
            _workspace_errors.push(AnalyzerError(
              sp.path, 0, 0, "unable to create storage directory"))
            _storage_path = None
          else
            try
              let fi = FileInfo(sp)?
              if not fi.directory then
                _log(Error) and _log.log(sp.path + " is not a directory")
                _workspace_errors.push(AnalyzerError(
                  sp.path, 0, 0, "storage path is not a directory"))
              else
                _storage_path = sp
              end
            else
              _log(Error) and _log.log(sp.path + " unable to stat")
              _workspace_errors.push(AnalyzerError(
                sp.path, 0, 0, "unable to stat storage path"))
            end
          end
        else
          _log(Error) and _log.log("unable to build storage path")
          _workspace_errors.push(AnalyzerError(
            fp.path, 0, 0, "unable to build storage path"))
        end
      end
    end
    match _storage_path
    | let sp: FilePath =>
      _log(Fine) and _log.log("storage_path is " + sp.path)
    else
      _log(Fine) and _log.log("storage path is None")
    end

    match _ponyc_executable
    | let fp: FilePath =>
      // calling code should set this from PATH
      let pe =
        match try fp.canonical()? end
        | let fp': FilePath =>
          _ponyc_executable = fp'
          fp'
        else
          fp
        end
      try
        let info = FileInfo(pe)?
        if not info.file then
          _log(Error) and _log.log(fp.path + " is not a file")
          _workspace_errors.push(AnalyzerError(
            pe.path, 0, 0, "ponyc executable is not a file"))
          _ponyc_executable = None
        end
      else
        _log(Error) and _log.log(fp.path + " does not exist")
        _workspace_errors.push(AnalyzerError(
          pe.path, 0, 0, "ponyc executable does not exist"))
      end
    end
    match _ponyc_executable
    | let pe: FilePath =>
      _log(Fine) and _log.log("ponyc_executable is " + pe.path)
    else
      _log(Fine) and _log.log("ponyc_executable is None")
    end

    match _pony_packages_path
    | let fp: FilePath =>
      let pp =
        match try fp.canonical()? end
        | let fp': FilePath =>
          _pony_packages_path = fp'
          fp'
        else
          fp
        end
      try
        let info = FileInfo(pp)?
        if not info.directory then
          _log(Error) and _log.log(fp.path + " is not a directory")
          _workspace_errors.push(AnalyzerError(
            pp.path, 0, 0, "pony packages path is not a directory"))
          _pony_packages_path = None
        end
      else
        _log(Error) and _log.log(fp.path + " does not exist")
        _workspace_errors.push(AnalyzerError(
          pp.path, 0, 0, "pony packages path does not exist"))
        _pony_packages_path = None
      end
    else
      match _ponyc_executable
      | let pe: FilePath =>
        try
          (let dir, _) = Path.split(pe.path)
          let pp =
            FilePath(_auth, Path.join(dir, "../../packages")).canonical()?
          if pp.exists() then
            let fi = FileInfo(pp)?
            if fi.directory then
              _pony_packages_path = pp
            end
          end
        end
      end
    end
    match _pony_packages_path
    | let pp: FilePath =>
      _log(Fine) and _log.log("pony_packages_path is " + pp.path)
    else
      _log(Fine) and _log.log("pony_packages_path is None")
    end

    // if we are in a workspace, start analyzing
    match _workspace
    | let workspace_path: FilePath =>
      analyze(0, workspace_path.path)
    end

  be _add_parse_error(
    canonical_path: String,
    line: USize,
    column: USize,
    message: String)
  =>
    _parse_errors.push(AnalyzerError(canonical_path, line, column, message))
    try
      let src_file = _src_files(canonical_path)?
      src_file.state = ParseError
      _log(Fine) and _log.log("enqueing as ParseError: " + canonical_path)
      _src_file_queue.push(src_file)
    end

  be _start_analyze_file(task_id: USize, canonical_path: String) =>
    try
      let storage_prefix = _storage_prefix(canonical_path)?
      let src_file = SrcFile(canonical_path, storage_prefix)
      src_file.task_id = task_id
      _src_files.update(canonical_path, src_file)
      _log(Fine) and _log.log(
        task_id.string() + ": enqueueing as Unknown: " + canonical_path +
        " (" + storage_prefix + ")")
      _src_file_queue.push(src_file)
    else
      _log(Error) and _log.log(
        "unable to get storage prefix for " + canonical_path)
    end

  be _process_src_file_queue() =>
    if _src_file_queue.size() > 0 then
      try
        let src_file = _src_file_queue.shift()?
        _process_src_file(src_file)
      end
      _process_src_file_queue()
    elseif _analysis_in_progress then
      _log(Fine) and _log.log("analysis finished; notifying")

      let ke: Array[AnalyzerError] trn =
        Array[AnalyzerError](_workspace_errors.size())
      for err in _workspace_errors.values() do ke.push(err) end

      let pe: Array[AnalyzerError] trn =
        Array[AnalyzerError](_parse_errors.size())
      for err in _parse_errors.values() do pe.push(err) end

      let le: Array[AnalyzerError] trn =
        Array[AnalyzerError](_lint_errors.size())
      for err in _lint_errors.values() do le.push(err) end

      let ae: Array[AnalyzerError] trn =
        Array[AnalyzerError](_analyze_errors.size())
      for err in _analyze_errors.values() do ae.push(err) end

      _analysis_in_progress = false
      _notify.analyzed_workspace(
        this,
        _analysis_task_id,
        consume ke,
        consume pe,
        consume le,
        consume ae)
    end

  fun _log_queue() =>
    if _log(Fine) then
      let message: String trn = String
      message.append("queue: [ ")
      for src_file in _src_file_queue.values() do
        message.append(src_file.task_id.string())
        message.append(" ")
      end
      message.append("]")
      _log.log(consume message)
    end

  fun ref _process_src_file(src_file: SrcFile) =>
    match src_file.state
    | Unknown =>
      if src_file.is_open then
        if _is_due(src_file.schedule) then
          src_file.state = NeedsParse
          _src_file_queue.push(src_file)
          // _log(Fine) and _log.log(
          //   "enqueueing as NeedsParse: " + src_file.canonical_path)
          // _log_queue()
        else
          _src_file_queue.push(src_file)
        end
      else
        let src_file_path = FilePath(_auth, src_file.canonical_path)
        let syntax_tree_path = FilePath(_auth, _syntax_tree_path(src_file))
        if syntax_tree_path.exists() then
          if _source_is_newer(src_file_path, syntax_tree_path) then
            src_file.state = NeedsParse
            _src_file_queue.push(src_file)
            // _log(Fine) and _log.log(
            //   "enqueueing as NeedsParse: " + src_file.canonical_path)
            // _log_queue()
          else
            _log(Fine) and _log.log(
              src_file.task_id.string() + ": " + src_file.canonical_path +
              " is up to date on disk")
            src_file.state = UpToDate
            _src_file_queue.push(src_file)
            // _log_queue()
          end
        else
          src_file.state = NeedsParse
          _src_file_queue.push(src_file)
          // _log(Fine) and _log.log(
          //   "enqueueing as NeedsParse: " + src_file.canonical_path)
          // _log_queue()
        end
      end
    | NeedsParse =>
      src_file.state = Parsing
      _src_file_queue.push(src_file)
      // _log(Fine) and _log.log(
      //   "enqueueing as Parsing: " + src_file.canonical_path)
      // _log_queue()
      if src_file.is_open then
        _log(Fine) and _log.log(
          src_file.task_id.string() + ": parsing in memory " +
          src_file.canonical_path)
        _parse_open_file(src_file)
      else
        _log(Fine) and _log.log(
          src_file.task_id.string() + ": parsing on disk " +
          src_file.canonical_path)
        _parse_src_file(src_file)
      end
    | Parsing =>
      _src_file_queue.push(src_file)
    | ParseError =>
      var errors: Array[AnalyzerError] trn = Array[AnalyzerError]
      errors = _collect_errors(
        src_file.canonical_path, _workspace_errors, consume errors)
      errors = _collect_errors(
        src_file.canonical_path, _parse_errors, consume errors)
      let errors': Array[AnalyzerError] val = consume errors
      _notify.analyze_failed(
        this,
        src_file.task_id,
        src_file.canonical_path,
        errors')
      try _src_files.remove(src_file.canonical_path)? end
    | UpToDate =>
      if src_file.is_open then
        _log(Fine) and _log.log(
          src_file.task_id.string() + ": up to date " + src_file.canonical_path)
        // _log_queue()
        var pe: Array[AnalyzerError] trn = Array[AnalyzerError]
        pe = _collect_errors(
          src_file.canonical_path, _parse_errors, consume pe)
        let pe': Array[AnalyzerError] val = consume pe
        var le: Array[AnalyzerError] trn = Array[AnalyzerError]
        le = _collect_errors(
          src_file.canonical_path, _lint_errors, consume le)
        let le': Array[AnalyzerError] val = consume le
        var ae: Array[AnalyzerError] trn = Array[AnalyzerError]
        ae = _collect_errors(
          src_file.canonical_path, _analyze_errors, consume ae)
        let ae': Array[AnalyzerError] val = consume ae
        _notify.analyzed_file(
          this,
          src_file.task_id,
          src_file.canonical_path,
          src_file.syntax_tree,
          None,
          pe',
          le',
          ae')
      else
        try
          _src_files.remove(src_file.canonical_path)?
        end
      end
    end

  fun _schedule(millis: U64): (I64, I64) =>
    (var secs, var nanos) = Time.now()
    nanos = nanos + I64.from[U64](Nanos.from_millis(millis))
    while nanos > 1_000_000_000 do
      nanos = nanos - 1_000_000_000
      secs = secs + 1
    end
    (secs, nanos)

  fun _is_due(schedule: (I64, I64)): Bool =>
    (let secs, let nanos) = Time.now()
    if secs > schedule._1 then
      true
    elseif secs < schedule._1 then
      false
    else
      nanos > schedule._2
    end

  fun _collect_errors(
    canonical_path: String,
    src: Array[AnalyzerError],
    dest: Array[AnalyzerError] trn)
    : Array[AnalyzerError] trn^
  =>
    for err in src.values() do
      if err.canonical_path == canonical_path then
        dest.push(err)
      end
    end
    consume dest

  fun ref _parse_open_file(src_file: SrcFile) =>
    let task_id = src_file.task_id
    let canonical_path = src_file.canonical_path
    match src_file.parse
    | let parse': parser.Parser =>
      _parse(task_id, canonical_path, parse')
    else
      _log(Error) and _log.log(
        task_id.string() + ": parse failed for " + canonical_path + "; no data")
    end

  fun ref _parse_src_file(src_file: SrcFile) =>
    let task_id = src_file.task_id
    let canonical_path = src_file.canonical_path
    match OpenFile(FilePath(_auth, src_file.canonical_path))
    | let file: File ref =>
      let source = file.read(file.size())
      let segments: Array[ReadSeq[U8] val] val =
        [ as ReadSeq[U8] val: consume source ]
      let parse = parser.Parser(segments)
      _parse(task_id, canonical_path, parse)
    else
      _log(Error) and _log.log("unable to read " + canonical_path)
      _analyze_errors.push(AnalyzerError(
        canonical_path, 0, 0, "unable to read file"))
      src_file.state = ParseError
      _src_file_queue.push(src_file)
      // _log(Fine) and _log.log("enqueueing as ParseError: " + canonical_path)
      // _log_queue()
    end

  fun _parse(
    task_id: USize,
    canonical_path: String,
    parse: parser.Parser)
  =>
    let self: EohippusAnalyzer tag = this
    parse.parse(
      _grammar,
      parser.Data(canonical_path),
      {(result: parser.Result, values: ast.NodeSeq) =>
        match result
        | let success: parser.Success =>
          try
            match values(0)?
            | let node: ast.NodeWith[ast.SrcFile] =>
              self._parsed_file(task_id, canonical_path, node)
            else
              _log(Error) and _log.log(
                canonical_path + ": root node was not SrcFile")
              self._add_parse_error(
                canonical_path, 0, 0, "root node was not SrcFile")
            end
          else
            _log(Error) and _log.log(
              canonical_path + "failed to get SrcFile node")
            self._add_parse_error(
              canonical_path, 0, 0, "failed to get SrcFile node")
          end
        | let failure: parser.Failure =>
          _log(Error) and _log.log(
            canonical_path + ": " + failure.get_message())
          self._add_parse_error(canonical_path, 0, 0, failure.get_message())
        end
      })

  be _parsed_file(
    task_id: USize,
    canonical_path: String,
    node: ast.NodeWith[ast.SrcFile])
  =>
    try
      let src_file = _src_files(canonical_path)?
      if src_file.task_id != task_id then
        _log(Fine) and _log.log(
          "abandoning parse for task_id " + task_id.string() +
          "; src_file is newer: " + src_file.task_id.string())
        return
      end

      _log(Fine) and _log.log(
        "parsed source file; writing syntax tree for " + canonical_path)
      let syntax_tree = recover val ast.SyntaxTree(node) end
      src_file.syntax_tree = syntax_tree
      _write_syntax_tree(src_file, syntax_tree)
      src_file.state = UpToDate
      // _log(Fine) and _log.log("setting UpToDate: " + canonical_path)
      // _log_queue()
    else
      _log(Error) and _log.log("parsed untracked source file " + canonical_path)
    end

  fun ref _write_syntax_tree(
    src_file: SrcFile,
    syntax_tree: ast.SyntaxTree box)
  =>
    let syntax_tree_path = _syntax_tree_path(src_file)
    (let dir, _) = Path.split(syntax_tree_path)
    let dir_path = FilePath(_auth, dir)
    if (not dir_path.exists()) and (not dir_path.mkdir()) then
      _log(Error) and _log.log("unable to create directory " + dir_path.path)
      _workspace_errors.push(AnalyzerError(
        dir_path.path, 0, 0, "unable to create storage directory"))
    end

    match CreateFile(FilePath(_auth, syntax_tree_path))
    | let file: File =>
      file.set_length(0)
      let json = syntax_tree.root.get_json()
      let json_str =
        ifdef debug then
          json.get_string(true)
        else
          json.get_string(false)
        end
      _log(Fine) and _log.log(
        src_file.task_id.string() + ": writing " + syntax_tree_path)
      if not file.write(consume json_str) then
        _log(Error) and _log.log(
          src_file.canonical_path + ": unable to write syntax tree file " +
          syntax_tree_path)
        _workspace_errors.push(AnalyzerError(
          src_file.canonical_path, 0, 0,
          "unable to write syntax tree file" + syntax_tree_path))
      end
    else
      _log(Error) and _log.log(
        src_file.canonical_path + ": unable to create syntax tree file " +
        syntax_tree_path)
      _workspace_errors.push(AnalyzerError(
        src_file.canonical_path, 0, 0,
        "unable to create syntax tree file " + syntax_tree_path))
    end

  fun _storage_prefix(canonical_path: String): String ? =>
    match (_workspace, _storage_path)
    | (let workspace_path: FilePath, let storage_path: FilePath) =>
      if
        canonical_path.compare_sub(
          workspace_path.path, workspace_path.path.size(), 0, 0) is Equal
      then
        let rest = canonical_path.substring(
          ISize.from[USize](workspace_path.path.size() + 1))
        Path.join(storage_path.path, consume rest)
      else
        let rest = canonical_path.clone() .> replace(":", "_")
        Path.join(storage_path.path, consume rest)
      end
    else
      _log(Warn) and _log.log("no workspace or storage")
      error
    end

  fun _source_is_newer(source: FilePath, other: FilePath): Bool =>
    (let source_secs, let source_nanos) =
      try
        FileInfo(source)?.modified_time
      else
        _log(Error) and _log.log("unable to stat " + source.path)
        return false
      end
    (let other_secs, let other_nanos) =
      try
        FileInfo(other)?.modified_time
      else
        _log(Error) and _log.log("unable to stat " + other.path)
        return false
      end
    if source_secs > other_secs then
      return true
    elseif source_secs < other_secs then
      return false
    else
      return source_nanos > other_nanos
    end

  fun _syntax_tree_path(src_file: SrcFile box): String =>
    src_file.storage_prefix + ".syntax.json"

  be analyze(task_id: USize, canonical_path: String) =>
    if _disposing then return end
    _log(Fine) and _log.log(task_id.string() + ": analyzing " + canonical_path)

    try
      let fp = FilePath(_auth, canonical_path)
      let fi = FileInfo(fp)?
      if fi.directory then
        _analysis_in_progress = true
        _analysis_task_id = task_id
        _workspace_errors.clear()
        _parse_errors.clear()
        _lint_errors.clear()
        _analyze_errors.clear()
        let self: EohippusAnalyzer tag = this
        fp.walk(
          {(dir_path: FilePath, entries: Array[String]) =>
            for entry in entries.values() do
              if (entry.size() > 5) and
                (entry.compare_sub(
                  ".pony", 5, ISize.from[USize](entry.size() - 5), 0, true) is
                 Equal)
              then
                self._start_analyze_file(task_id,
                  Path.join(dir_path.path, entry))
              end
            end
          })
        _process_src_file_queue()
      elseif fi.file then
        (let dir, _) = Path.split(canonical_path)
        analyze(task_id, dir)
      else
        _log(Warn) and _log.log(task_id.string() + ": " + canonical_path +
          " is neither a file nor a directory; nothing to do")
      end
    else
      _log(Error) and _log.log(
        task_id.string() + "error opening " + canonical_path)
      _notify.analyze_failed(
        this,
        task_id,
        canonical_path,
        [ AnalyzerError(
            canonical_path, 0, 0, "error opening " + canonical_path)
        ])
    end

  be open_file(task_id: USize, canonical_path: String, parse: parser.Parser) =>
    if _disposing then return end
    _log(Fine) and _log.log(task_id.string() + ": opening " + canonical_path)
    try
      let src_file = _src_files(canonical_path)?
      let needs_queue = src_file.state is UpToDate
      src_file.task_id = task_id
      src_file.state = NeedsParse
      src_file.schedule = _schedule(0)
      src_file.is_open = true
      src_file.parse = parse
      if needs_queue then
        _src_file_queue.push(src_file)
      end
      // _log(Fine) and _log.log("found in-memory file; setting NeedsParse")
      // _log_queue()
    else
      try
        let storage_prefix = _storage_prefix(canonical_path)?
        let src_file = SrcFile(
          canonical_path,
          storage_prefix)
        src_file.task_id = task_id
        src_file.state = NeedsParse
        src_file.is_open = true
        src_file.schedule = _schedule(0)
        src_file.parse = parse
        _src_files.update(canonical_path, src_file)
        _src_file_queue.push(src_file)
        // _log(Fine) and _log.log("enqueueing as Unknown: " + canonical_path)
        // _log_queue()
      else
        _log(Error) and _log.log(
          task_id.string() + " unable to open " + canonical_path +
          "; unable to build storage prefix")
        return
      end
    end
    _process_src_file_queue()

  be update_file(
    task_id: USize,
    canonical_path: String,
    parse: parser.Parser)
  =>
    if _disposing then return end
    _log(Fine) and _log.log(task_id.string() + ": updating " + canonical_path)
    try
      let src_file = _src_files(canonical_path)?
      let needs_queue = src_file.state is UpToDate
      src_file.task_id = task_id
      src_file.state = Unknown
      src_file.schedule = _schedule(300)
      src_file.is_open = true
      src_file.parse = parse
      if needs_queue then
        _src_file_queue.push(src_file)
      end
      // _log(Fine) and _log.log("found in-memory file")
      // _log_queue()
    else
      try
        let storage_prefix = _storage_prefix(canonical_path)?
        let src_file = SrcFile(
          canonical_path,
          storage_prefix)
        src_file.task_id = task_id
        src_file.state = Unknown
        src_file.is_open = true
        src_file.schedule = _schedule(300)
        src_file.parse = parse
        _src_files.update(canonical_path, src_file)
        _src_file_queue.push(src_file)
        // _log(Fine) and _log.log("enqueueing as Unknown: " + canonical_path)
        // _log_queue()
      else
        _log(Error) and _log.log(
          task_id.string() + " unable to update " + canonical_path +
          "; unable to build storage prefix")
        return
      end
    end
    _process_src_file_queue()

  be close_file(task_id: USize, canonical_path: String) =>
    try
      let src_file = _src_files(canonical_path)?
      src_file.is_open = false
    end

  be dispose() =>
    _disposing = true
