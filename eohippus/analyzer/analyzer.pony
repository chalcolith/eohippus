use "collections"
use "files"
use "itertools"
use "logger"
use "time"

use ast = "../ast"
use json = "../json"
use linter = "../linter"
use parser = "../parser"
use ".."

interface tag Analyzer
  be open_file(task_id: USize, canonical_path: String, parse: parser.Parser)
  be update_file(task_id: USize, canonical_path: String, parse: parser.Parser)
  be close_file(task_id: USize, canonical_path: String)
  be request_info(
    task_id: USize, canonical_path: String, notify: AnalyzerRequestNotify)
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

  let _lint_configs: Map[String, linter.Config val] = _lint_configs.create()

  let _src_items: Map[String, SrcItem] = _src_items.create()
  let _src_item_queue: Queue[SrcItem] = _src_item_queue.create()

  var _analysis_task_id: USize = 1_000_000
  let _workspace_errors: Map[String, Array[AnalyzerError]] =
    _workspace_errors.create()
  let _parse_errors: Map[String, Array[AnalyzerError]] =
    _parse_errors.create()
  let _lint_errors: Map[String, Array[AnalyzerError]] =
    _lint_errors.create()
  let _analyze_errors: Map[String, Array[AnalyzerError]] =
    _analyze_errors.create()

  let _pending_requests: Map[String, MapIs[AnalyzerRequestNotify, Set[USize]]] =
    _pending_requests.create()

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
          _workspace_errors(ws.path) =
            [ AnalyzerError(
                ws.path, AnalyzeError, "workspace is not a directory") ]
          _workspace = None
        end
      else
        _log(Error) and _log.log(fp.path + " does not exist")
        _workspace_errors(ws.path) =
          [ AnalyzerError(
              ws.path, AnalyzeError, "workspace directory does not exist") ]
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
          _workspace_errors(sp.path) =
            [ AnalyzerError(
                sp.path, AnalyzeError, "storage path is not a directory") ]
          _storage_path = None
        end
      else
        _log(Error) and _log.log(fp.path + " unable to stat")
        _workspace_errors(sp.path) =
          [ AnalyzerError(
              sp.path, AnalyzeError, "unable to stat storage path") ]
        _storage_path = None
      end
    else
      match _workspace
      | let fp: FilePath =>
        try
          let sp = fp.join(".eohippus")?
          if (not sp.exists() and not sp.mkdir()) then
            _log(Error) and _log.log("unable to create " + sp.path)
            _workspace_errors(sp.path) =
              [ AnalyzerError(
                  sp.path, AnalyzeError, "unable to create storage directory") ]
            _storage_path = None
          else
            try
              let fi = FileInfo(sp)?
              if not fi.directory then
                _log(Error) and _log.log(sp.path + " is not a directory")
                _workspace_errors(sp.path) =
                  [ AnalyzerError(
                      sp.path, AnalyzeError, "storage path is not a directory") ]
              else
                _storage_path = sp
              end
            else
              _log(Error) and _log.log(sp.path + " unable to stat")
              _workspace_errors(sp.path) =
                [ AnalyzerError(
                    sp.path, AnalyzeError, "unable to stat storage path") ]
            end
          end
        else
          _log(Error) and _log.log("unable to build storage path")
          _workspace_errors(fp.path) =
            [ AnalyzerError(
                fp.path, AnalyzeError, "unable to build storage path") ]
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
          _workspace_errors(pe.path) =
            [ AnalyzerError(
                pe.path, AnalyzeError, "ponyc executable is not a file") ]
          _ponyc_executable = None
        end
      else
        _log(Error) and _log.log(fp.path + " does not exist")
        _workspace_errors(pe.path) =
          [ AnalyzerError(
              pe.path, AnalyzeError, "ponyc executable does not exist") ]
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
          _workspace_errors(pp.path) =
            [ AnalyzerError(
                pp.path, AnalyzeError, "pony packages path is not a directory") ]
          _pony_packages_path = None
        end
      else
        _log(Error) and _log.log(fp.path + " does not exist")
        _workspace_errors(pp.path) =
          [ AnalyzerError(
              pp.path, AnalyzeError, "pony packages path does not exist") ]
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
      //analyze(_analysis_task_id, Path.join(pp.path, "builtin"))
      _analysis_task_id = _analysis_task_id + 1
    else
      _log(Fine) and _log.log("pony_packages_path is None")
    end

    // if we are in a workspace, start analyzing
    match _workspace
    | let workspace_path: FilePath =>
      analyze(_analysis_task_id, workspace_path.path)
      _analysis_task_id = _analysis_task_id + 1
    end

  fun ref _get_next_task_id(): USize =>
    let result = _analysis_task_id
    _analysis_task_id = _analysis_task_id + 1
    result

  be analyze(task_id: USize, canonical_path: String) =>
    if _disposing then return end
    _log(Fine) and _log.log(task_id.string() + ": analyzing " + canonical_path)

    try
      let fp = FilePath(_auth, canonical_path)
      let fi = FileInfo(fp)?
      if fi.directory then
        _workspace_errors.clear()
        _parse_errors.clear()
        _lint_errors.clear()
        _analyze_errors.clear()
        let self: EohippusAnalyzer tag = this
        var first = true
        fp.walk(
          {(dir_path: FilePath, entries: Array[String]) =>
            let package_path = dir_path.path
            let package = SrcPackageItem(package_path)
            if first then
              package.is_workspace = true
              first = false
            end
            package.task_id = task_id

            (let parent, let dir_name) = Path.split(dir_path.path)
            try
              if dir_name(0)? == '.' then return end
            end
            match try _src_items(parent)? end
            | let parent_package: SrcPackageItem =>
              parent_package.dependencies.push(package)
              package.parent_package = parent_package
            end

            for entry in entries.values() do
              if self._is_pony_file(entry) then
                let file_canonical_path = Path.join(dir_path.path, entry)
                let src_file = SrcFileItem(file_canonical_path)
                src_file.task_id = task_id
                src_file.parent_package = package
                _src_items.update(file_canonical_path, src_file)
                _src_item_queue.push(src_file)
                package.dependencies.push(src_file)
                _log(Fine) and _log.log(
                  task_id.string() + ": enqueueing " + file_canonical_path)
              end
            end
            _src_items.update(package_path, package)
            _src_item_queue.push(package)
          })
        _process_src_item_queue()
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
            canonical_path, AnalyzeError, "error opening " + canonical_path) ])
    end

  fun tag _is_pony_file(fname: String): Bool =>
    let ext_size = ".pony".size()
    if fname.size() <= ext_size then
      return false
    end
    let index = ISize.from[USize](fname.size() - ext_size)
    fname.compare_sub(
      ".pony", ext_size, index where ignore_case = true) is Equal

  be open_file(task_id: USize, canonical_path: String, parse: parser.Parser) =>
    if _disposing then return end
    _log(Fine) and _log.log(task_id.string() + ": opening " + canonical_path)
    match try _src_items(canonical_path)? end
    | let src_file: SrcFileItem =>
      let needs_queue =
        (src_file.state is AnalysisUpToDate) or
        (src_file.state is AnalysisError)
      src_file.task_id = task_id
      src_file.state = AnalysisStart
      src_file.schedule = _schedule(0)
      src_file.is_open = true
      src_file.parse = parse
      if needs_queue then
        _src_item_queue.push(src_file)
      end
    else
      let src_file = SrcFileItem(canonical_path)
      src_file.task_id = task_id
      src_file.state = AnalysisStart
      src_file.is_open = true
      src_file.schedule = _schedule(0)
      src_file.parse = parse
      _src_items.update(canonical_path, src_file)
      _src_item_queue.push(src_file)
    end
    _process_src_item_queue()

  be update_file(
    task_id: USize,
    canonical_path: String,
    parse: parser.Parser)
  =>
    if _disposing then return end
    _log(Fine) and _log.log(task_id.string() + ": updating " + canonical_path)
    match try _src_items(canonical_path)? end
    | let src_file: SrcFileItem =>
      let needs_queue =
        (src_file.state is AnalysisUpToDate) or
        (src_file.state is AnalysisError)
      src_file.task_id = task_id
      src_file.state = AnalysisStart
      src_file.schedule = _schedule(300)
      src_file.is_open = true
      src_file.parse = parse
      _log(Fine) and _log.log(task_id.string() + ": found in-memory file")
      if needs_queue then
        _src_item_queue.push(src_file)
      end
    else
      let src_file = SrcFileItem(canonical_path)
      src_file.task_id = task_id
      src_file.state = AnalysisStart
      src_file.is_open = true
      src_file.schedule = _schedule(300)
      src_file.parse = parse
      _src_items.update(canonical_path, src_file)
      _src_item_queue.push(src_file)
      _log(Fine) and _log.log(
        task_id.string() + ": in-memory file not found; creating")
    end
    _process_src_item_queue()

  be close_file(task_id: USize, canonical_path: String) =>
    match try _src_items(canonical_path)? end
    | let src_file: SrcFileItem =>
      src_file.is_open = false
    end

  be request_info(
    task_id: USize, canonical_path: String, notify: AnalyzerRequestNotify)
  =>
    _log(Fine) and _log.log(task_id.string() + ": request " + canonical_path)

    if not _src_items.contains(canonical_path) then
      analyze(task_id, canonical_path)
    end

    let notifys =
      match try _pending_requests(canonical_path)? end
      | let notifys': MapIs[AnalyzerRequestNotify, Set[USize]] =>
        notifys'
      else
        let notifys' = MapIs[AnalyzerRequestNotify, Set[USize]]
        _pending_requests.update(canonical_path, notifys')
        notifys'
      end
    let task_ids =
      match try notifys(notify)? end
      | let task_ids': Set[USize] =>
        task_ids'
      else
        let task_ids = Set[USize]
        notifys.update(notify, task_ids)
        task_ids
      end
    task_ids.set(task_id)

    _process_src_item_queue()

  be dispose() =>
    _disposing = true

  fun ref _push_error(
    errors: Map[String, Array[AnalyzerError]],
    new_error: AnalyzerError)
  =>
    let arr =
      match try errors(new_error.canonical_path)? end
      | let arr': Array[AnalyzerError] =>
        arr'
      else
        let arr' = Array[AnalyzerError]
        errors(new_error.canonical_path) = arr'
        arr'
      end
    arr.push(new_error)

  fun ref _clear_errors(
    canonical_path: String,
    errors: Map[String, Array[AnalyzerError]])
  =>
    try
      errors.remove(canonical_path)?
    end

  fun ref _clear_and_push(
    canonical_path: String,
    errors: Map[String, Array[AnalyzerError]],
    new_error: AnalyzerError)
  =>
    let arr =
      match try errors(new_error.canonical_path)? end
      | let arr': Array[AnalyzerError] =>
        arr'.clear()
        arr'
      else
        let arr' = Array[AnalyzerError]
        errors(new_error.canonical_path) = arr'
        arr'
      end
    arr.push(new_error)

  fun _collect_errors(
    errors: Map[String, Array[AnalyzerError]],
    canonical_path: (String | None) = None)
    : Array[AnalyzerError] val
  =>
    let result: Array[AnalyzerError] trn = Array[AnalyzerError]
    match canonical_path
    | let key: String =>
      try
        for err in errors(key)?.values() do
          result.push(err)
        end
      end
    else
      for key in errors.keys() do
        try
          for err in errors(key)?.values() do
            result.push(err)
          end
        end
      end
    end
    consume result

  be _process_src_item_queue() =>
    if _disposing then return end

    if _src_item_queue.size() > 0 then
      try
        let src_item = _src_item_queue.shift()?
        _process_src_item(src_item)
      end
    end

    _process_pending_requests()

    if _src_item_queue.size() > 0 then
      _process_src_item_queue()
    end

  fun ref _process_src_item(src_item: SrcItem) =>
    match src_item
    | let file_item: SrcFileItem =>
      _process_file_item(file_item)
    | let package_item: SrcPackageItem =>
      _process_package_item(package_item)
    end

  fun ref _process_package_item(package_item: SrcPackageItem) =>
    var needs_push = false
    match package_item.state
    | AnalysisStart =>
      _log(Fine) and _log.log(package_item.canonical_path + " => Parsing")
      package_item.state = AnalysisParsing
      needs_push = true
    | AnalysisParsing =>
      var any_parsing = false
      var any_error = false
      for dep in package_item.dependencies.values() do
        if dep.state_value() <= AnalysisParsing() then
          any_parsing = true
        end
        if dep.state_value() == AnalysisError() then
          any_error = true
        end
      end
      if any_error then
        _log(Fine) and _log.log(
          package_item.task_id.string() + ": package " +
          package_item.canonical_path + " => Error")
        package_item.state = AnalysisError
      elseif not any_parsing then
        _log(Fine) and _log.log(
          package_item.task_id.string() + ": package " +
          package_item.canonical_path + " => Scoping")
        package_item.state = AnalysisScoping
        needs_push = true
      else
        needs_push = true
      end
    | AnalysisScoping =>
      var any_scoping = false
      var any_error = false
      for dep in package_item.dependencies.values() do
        if dep.state_value() <= AnalysisScoping() then
          any_scoping = true
        end
        if dep.state_value() == AnalysisError() then
          any_error = true
        end
      end
      if any_error then
        _log(Fine) and _log.log(
          package_item.task_id.string() + ": package " +
          package_item.canonical_path + " => Error")
        package_item.state = AnalysisError
      elseif not any_scoping then
        _log(Fine) and _log.log(
          package_item.task_id.string() + ": package " +
          package_item.canonical_path + " => Linting")
        package_item.state = AnalysisLinting
        needs_push = true
      else
        needs_push = true
      end
    | AnalysisLinting =>
      var any_linting = false
      var any_error = false
      for dep in package_item.dependencies.values() do
        if dep.state_value() <= AnalysisLinting() then
          any_linting = true
        end
        if dep.state_value() == AnalysisError() then
          any_error = true
        end
      end
      if any_error then
        package_item.state = AnalysisError
      elseif not any_linting then
        package_item.state = AnalysisUpToDate
        needs_push = true
      else
        needs_push = true
      end
    | AnalysisError =>
      _log(Error) and _log.log(
        package_item.task_id.string() + ": PACKAGE ERROR: " +
        package_item.canonical_path)
    | AnalysisUpToDate =>
      _log(Fine) and _log.log(
        package_item.task_id.string() + ": package up to date: " +
        package_item.canonical_path)

      if package_item.is_workspace then
        _log(Fine) and _log.log(
          package_item.task_id.string() + ": workspace up to date; notifying")

        _notify.analyzed_workspace(
          this,
          package_item.task_id,
          _collect_errors(_workspace_errors),
          _collect_errors(_parse_errors),
          _collect_errors(_lint_errors),
          _collect_errors(_analyze_errors))
      end
    end
    if needs_push then
      _src_item_queue.push(package_item)
    end

  fun ref _process_file_item(src_file: SrcFileItem) =>
    var needs_push = false
    match src_file.state
    | AnalysisStart =>
      try
        src_file.storage_prefix = _storage_prefix(src_file.canonical_path)?
      end

      try _workspace_errors.remove(src_file.canonical_path)? end
      try _parse_errors.remove(src_file.canonical_path)? end
      try _lint_errors.remove(src_file.canonical_path)? end
      try _analyze_errors.remove(src_file.canonical_path)? end

      if src_file.is_open then
        if _is_due(src_file.schedule) then
          src_file.state = AnalysisParsing
        end
      else
        src_file.state = AnalysisParsing
      end

      if src_file.state is AnalysisParsing then
        _log(Fine) and _log.log(
          src_file.task_id.string() + ": " + src_file.canonical_path +
          " => Parsing")
      end

      needs_push = true
    | AnalysisParsing =>
      if src_file.is_open then
        _parse_open_file(src_file)
      else
        _parse_disk_file(src_file)
      end
    | AnalysisScoping =>
      _scope(src_file)
    | AnalysisLinting =>
      _lint(src_file)
    | AnalysisError =>
      var errors: Array[AnalyzerError] trn = Array[AnalyzerError]
      try
        for err in _workspace_errors(src_file.canonical_path)?.values() do
          errors.push(err)
        end
      end
      try
        for err in _parse_errors(src_file.canonical_path)?.values() do
          errors.push(err)
        end
      end
      try
        for err in _lint_errors(src_file.canonical_path)?.values() do
          errors.push(err)
        end
      end
      try
        for err in _analyze_errors(src_file.canonical_path)?.values() do
          errors.push(err)
        end
      end
      let errors': Array[AnalyzerError] val = consume errors
      _notify.analyze_failed(
        this,
        src_file.task_id,
        src_file.canonical_path,
        errors')
    | AnalysisUpToDate =>
      if src_file.is_open then
        _log(Fine) and _log.log(
          src_file.task_id.string() + ": file up to date: " +
          src_file.canonical_path)

        _notify.analyzed_file(
          this,
          src_file.task_id,
          src_file.canonical_path,
          src_file.syntax_tree,
          None,
          _collect_errors(_parse_errors, src_file.canonical_path),
          _collect_errors(_lint_errors, src_file.canonical_path),
          _collect_errors(_analyze_errors, src_file.canonical_path))
      end
    end
    if needs_push then
      _src_item_queue.push(src_file)
    end

  fun ref _process_pending_requests() =>
    let paths_done = Array[String]

    for (canonical_path, notifys) in _pending_requests.pairs() do
      match try _src_items(canonical_path)? end
      | let file_item: SrcFileItem =>
        match file_item.state
        | AnalysisUpToDate =>
          _pending_request_succeeded(file_item, notifys)
          paths_done.push(canonical_path)
        | AnalysisError =>
          _pending_request_failed(file_item, notifys)
          paths_done.push(canonical_path)
        end
      | let package_item: SrcPackageItem =>
        let up_to_date = Iter[SrcItem](package_item.dependencies.values())
          .all({(pi) => pi.state_value() is AnalysisUpToDate()})
        if up_to_date then
          _pending_request_succeeded(package_item, notifys)
          paths_done.push(canonical_path)
        else
          let any_errors = Iter[SrcItem](package_item.dependencies.values())
            .any({(pi) => pi.state_value() is AnalysisError()})
          if any_errors then
            _pending_request_failed(package_item, notifys)
            paths_done.push(canonical_path)
          end
        end
      end
    end

    for path in paths_done.values() do
      try
        _pending_requests.remove(path)?
      end
    end

  fun ref _pending_request_succeeded(
    src_item: (SrcFileItem | SrcPackageItem),
    notifys: MapIs[AnalyzerRequestNotify, Set[USize]])
  =>
    match src_item
    | let file_item: SrcFileItem =>
      match (file_item.syntax_tree, file_item.scope)
      | (let st: ast.Node, let sc: Scope val) =>
        for (notify, task_ids) in notifys.pairs() do
          for task_id in task_ids.values() do
            _log(Fine) and _log.log(
              task_id.string() + ": request succeeded: "
              + file_item.canonical_path)
            notify.request_succeeded(task_id, file_item.canonical_path, st, sc)
          end
        end
      end
    | let package_item: SrcPackageItem =>
      let package_scope: Scope trn = Scope(
        PackageScope,
        package_item.canonical_path,
        package_item.canonical_path,
        (0, 0, USize.max_value(), USize.max_value()))

      for dep in package_item.dependencies.values() do
        match dep
        | let file_item: SrcFileItem =>
          match file_item.scope
          | let child_scope: Scope val =>
            package_scope.add_child(child_scope)
          end
        end
      end

      let package_scope': Scope val = consume package_scope

      for (notify, task_ids) in notifys.pairs() do
        for task_id in task_ids.values() do
          _log(Fine) and _log.log(
            task_id.string() + ": request succeeded: "
            + package_item.canonical_path)
          notify.request_succeeded(
            task_id, package_item.canonical_path, None, package_scope')
        end
      end
    end

  fun ref _pending_request_failed(
    src_item: (SrcFileItem | SrcPackageItem),
    notifys: MapIs[AnalyzerRequestNotify, Set[USize]])
  =>
    for (notify, task_ids) in notifys.pairs() do
      for task_id in task_ids.values() do
        _log(Fine) and _log.log(
          task_id.string() + ": request failed: " + src_item.path())
        notify.request_failed(task_id, src_item.path(), "analysis failed")
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

  fun ref _parse_open_file(src_file: SrcFileItem) =>
    if _disposing then return end

    _log(Fine) and _log.log(
      src_file.task_id.string() + ": parsing in memory " +
      src_file.canonical_path)

    let task_id = src_file.task_id
    let canonical_path = src_file.canonical_path
    match src_file.parse
    | let parse': parser.Parser =>
      _parse(task_id, canonical_path, parse')
    else
      _log(Error) and _log.log(
        task_id.string() + ": parse failed for " + canonical_path + "; no data")
    end

  fun ref _parse_disk_file(src_file: SrcFileItem) =>
    if _disposing then return end

    _log(Fine) and _log.log(
      src_file.task_id.string() + ": parsing on disk " +
      src_file.canonical_path)

    let src_file_path = FilePath(_auth, src_file.canonical_path)
    let syntax_tree_path = FilePath(_auth, _syntax_tree_path(src_file))
    if
      syntax_tree_path.exists() and
      (not _source_is_newer(src_file_path, syntax_tree_path))
    then
      _log(Fine) and _log.log(
        src_file.task_id.string() + ": cache is newer; not parsing " +
        src_file.canonical_path)

      match _get_syntax_tree(src_file)
      | let syntax_tree: ast.Node =>
        _collect_error_sections(src_file.canonical_path, syntax_tree)
        src_file.syntax_tree = syntax_tree
      else
        _log(Error) and _log.log(
          src_file.task_id.string() + ": unable to load syntax for " +
          src_file.canonical_path)
        return
      end

      src_file.state = AnalysisScoping
      _src_item_queue.push(src_file)
      _process_src_item_queue()
      return
    end

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
      _push_error(_workspace_errors, AnalyzerError(
        canonical_path, AnalyzeError, "unable to read file"))
      src_file.state = AnalysisError
      _src_item_queue.push(src_file)
    end

  fun ref _parse(
    task_id: USize,
    canonical_path: String,
    parse: parser.Parser)
  =>
    if _disposing then return end

    //_log(Fine) and _log.log(task_id.string() + ": parsing " + canonical_path)
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
              // _log(Fine) and _log.log(
              //   task_id.string() + ": got SrcFile for " + canonical_path)
              self._parsed_file(task_id, canonical_path, node)
            else
              _log(Error) and _log.log(
                task_id.string() + ": " + canonical_path +
                  ": root node was not SrcFile")
              self._parse_failed(
                task_id, canonical_path, "root node was not SrcFile")
            end
          else
            _log(Error) and _log.log(
              task_id.string() + canonical_path + "failed to get SrcFile node")
            self._parse_failed(
              task_id, canonical_path, "failed to get SrcFile node")
          end
        | let failure: parser.Failure =>
          _log(Error) and _log.log(
            task_id.string() + ": " + canonical_path + ": " +
              failure.get_message())
          self._parse_failed(task_id, canonical_path, failure.get_message())
        end
      })

  fun ref _collect_error_sections(canonical_path: String, node: ast.Node) =>
    match node
    | let es: ast.NodeWith[ast.ErrorSection] =>
      let si = es.src_info()
      match (si.line, si.column, si.next_line, si.next_column)
      | (let l: USize, let c: USize, let nl: USize, let nc: USize) =>
        // _log(Fine) and _log.log(
        //   "ErrorSection " + canonical_path + ": " + l.string() + ":" +
        //   c.string() + "-" + nl.string() + ":" + nc.string())

        _push_error(
          _parse_errors,
          AnalyzerError(
            canonical_path, AnalyzeError, es.data().message, l, c, nl, nc))
      end
    end
    for child in node.children().values() do
      _collect_error_sections(canonical_path, child)
    end

  be _parsed_file(
    task_id: USize,
    canonical_path: String,
    node: ast.NodeWith[ast.SrcFile])
  =>
    if _disposing then return end

    match try _src_items(canonical_path)? end
    | let src_file: SrcFileItem =>
      if src_file.task_id != task_id then
        _log(Fine) and _log.log(
          "abandoning parse for task_id " + task_id.string() +
            "; src_file is newer: " + src_file.task_id.string())
        return
      end

      _clear_errors(canonical_path, _parse_errors)
      (let syntax_tree, let lb, let errors) = ast.SyntaxTree.add_line_info(node)
      if src_file.is_open then
        _notify.parsed_file(this, task_id, canonical_path, syntax_tree, lb)
      end

      if errors.size() > 0 then
        for (n, message) in errors.values() do
          _log(Error) and _log.log(
            task_id.string() + ": line error " + canonical_path + ": " + message)

          let si = n.src_info()
          match (si.line, si.column, si.next_line, si.next_column)
          | (let l: USize, let c: USize, let nl: USize, let nc: USize) =>
            _push_error(
              _parse_errors,
              AnalyzerError(canonical_path, AnalyzeError, message, l, c, nl, nc))
          else
            _push_error(
              _parse_errors,
              AnalyzerError(canonical_path, AnalyzeError, message))
          end
        end
        src_file.state = AnalysisError
        return
      end

      src_file.syntax_tree = syntax_tree
      src_file.make_indices()
      _write_syntax_tree(src_file)
      _collect_error_sections(canonical_path, syntax_tree)

      _log(Fine) and _log.log(
        src_file.task_id.string() + ": " + src_file.canonical_path +
        " => Scoping")

      src_file.state = AnalysisScoping
      _src_item_queue.push(src_file)
      _process_src_item_queue()
    else
      _log(Error) and _log.log(
        task_id.string() + ": parsed untracked source file " + canonical_path)
    end

  be _parse_failed(
    task_id: USize,
    canonical_path: String,
    message: String,
    line: USize = 0,
    column: USize = 0,
    next_line: USize = 0,
    next_column: USize = 0)
  =>
    if _disposing then return end

    match try _src_items(canonical_path)? end
    | let src_file: SrcFileItem =>
      if src_file.task_id != task_id then
        _log(Fine) and _log.log(
          task_id.string() + ": ignoring failed parse for " + canonical_path +
            "; src_file is newer: " + src_file.task_id.string())
        return
      end

      _log(Error) and _log.log(
        task_id.string() + ": parse failed for " + canonical_path)

      _push_error(_parse_errors, AnalyzerError(
        canonical_path,
        AnalyzeError,
        message,
        line,
        column,
        next_line,
        next_column))

      let error_section = ast.NodeWith[ast.ErrorSection](
        ast.SrcInfo(canonical_path), [], ast.ErrorSection(message))
      let node = ast.NodeWith[ast.SrcFile](
        ast.SrcInfo(canonical_path),
        [ error_section ],
        ast.SrcFile(canonical_path, [], [])
        where error_sections' = [ error_section ])
      _write_syntax_tree(src_file, node)

      _log(Fine) and _log.log(
        src_file.task_id.string() + ": " + src_file.canonical_path +
        " => Error")

      src_file.state = AnalysisError
      _src_item_queue.push(src_file)
      _process_src_item_queue()
    end

  fun ref _write_syntax_tree(
    src_file: SrcFileItem,
    syntax_tree: (ast.Node | None) = None)
  =>
    _log(Fine) and _log.log(
      src_file.task_id.string() + ": writing syntax tree for " +
      src_file.canonical_path)

    let st =
      match
        try
          syntax_tree as ast.Node
        else
          try src_file.syntax_tree as ast.Node end
        end
      | let node: ast.Node =>
        node
      else
        _log(Error) and _log.log("unable to get syntax tree to write")
        return
      end

    let syntax_tree_path = _syntax_tree_path(src_file)
    (let dir, _) = Path.split(syntax_tree_path)
    let dir_path = FilePath(_auth, dir)
    if (not dir_path.exists()) and (not dir_path.mkdir()) then
      _log(Error) and _log.log("unable to create directory " + dir_path.path)
      _push_error(_workspace_errors, AnalyzerError(
        dir_path.path, AnalyzeError, "unable to create storage directory"))
      return
    end

    match CreateFile(FilePath(_auth, syntax_tree_path))
    | let file: File =>
      file.set_length(0)
      let json_item = st.get_json()
      let json_str =
        ifdef debug then
          json_item.get_string(true)
        else
          json_item.get_string(false)
        end
      _log(Fine) and _log.log(
        src_file.task_id.string() + ": writing " + syntax_tree_path)
      if not file.write(consume json_str) then
        _log(Error) and _log.log(
          src_file.task_id.string() + ": unable to write syntax tree file " +
          syntax_tree_path)
        _push_error(_workspace_errors, AnalyzerError(
          src_file.canonical_path,
          AnalyzeError,
          "unable to write syntax tree file" + syntax_tree_path))
      end
    else
      _log(Error) and _log.log(
        src_file.canonical_path + ": unable to create syntax tree file " +
        syntax_tree_path)
      _push_error(_workspace_errors, AnalyzerError(
        src_file.canonical_path,
        AnalyzeError,
        "unable to create syntax tree file " + syntax_tree_path))
    end

  fun ref _get_syntax_tree(src_file: SrcFileItem): (ast.Node | None) =>
    match src_file.syntax_tree
    | let node: ast.Node =>
      node
    else
      let syntax_path = FilePath(_auth, _syntax_tree_path(src_file))
      match OpenFile(syntax_path)
      | let file: File =>
        let json_str = recover val file.read_string(file.size()) end
        match json.Parse(json_str)
        | let obj: json.Object =>
          match ast.ParseNode(src_file.canonical_path, obj)
          | let node: ast.Node =>
            _log(Fine) and _log.log(
              src_file.task_id.string() + ": loaded " + syntax_path.path)
            src_file.syntax_tree = node
            src_file.make_indices()
            return node
          | let err: String =>
            _log(Error) and _log.log(
              src_file.task_id.string() + ": error loading " +
              syntax_path.path + ": " + err)
          end
        | let item: json.Item =>
          _log(Error) and _log.log(
            src_file.task_id.string() + ": error loading " + syntax_path.path +
            ": a syntax tree must be an object")
        | let err: json.ParseError =>
          _log(Error) and _log.log(
            src_file.task_id.string() + ": error loading " + syntax_path.path +
            ":" + err.index.string() +
            ": " + err.message)
        end
      else
        _log(Error) and _log.log(
          src_file.task_id.string() + ": error opening " + syntax_path.path)
      end
      None
    end

  fun ref _scope(src_file: SrcFileItem) =>
    if _disposing then return end

    match src_file.parent_package
    | let package: SrcPackageItem =>
      if package.state() <= AnalysisParsing() then
        _src_item_queue.push(src_file)
        _process_src_item_queue()
        return
      elseif package.state() == AnalysisError() then
        _log(Error) and _log.log(
          src_file.task_id.string() + ": package has error, not scoping " +
            src_file.canonical_path)
        src_file.state = AnalysisError
        return
      end
    else
      _log(Error) and _log.log(
        src_file.task_id.string() + ": failed to get package item for " +
        src_file.canonical_path)
      src_file.state = AnalysisError
      return
    end

    _log(Fine) and _log.log(
      src_file.task_id.string() + ": scoping " + src_file.canonical_path)

    let src_file_path = FilePath(_auth, src_file.canonical_path)
    let scope_path = FilePath(_auth, _scope_path(src_file))
    if
      scope_path.exists() and
      (not _source_is_newer(src_file_path, scope_path))
    then
      _log(Fine) and _log.log(
        src_file.task_id.string() + ": cache is newer; not scoping " +
        src_file.canonical_path)
      match _get_scope(src_file)
      | let scope: Scope =>
        src_file.scope = scope
        src_file.state = AnalysisLinting
        _src_item_queue.push(src_file)
        _process_src_item_queue()
        return
      else
        _log(Error) and _log.log(
          src_file.task_id.string() + ": unable to load scope for " +
          src_file.canonical_path)
        return
      end
    end

    match _get_syntax_tree(src_file)
    | let syntax_tree: ast.Node =>
      let scoper = Scoper(_log, this)
      scoper.scope_syntax_tree(
        src_file.task_id,
        src_file.canonical_path,
        syntax_tree,
        src_file.node_indices)
    else
      _log(Error) and _log.log(
        src_file.task_id.string() + ": failed to get syntax tree for " +
        src_file.canonical_path)
      src_file.state = AnalysisError
    end

  fun ref _get_scope(src_file: SrcFileItem): (Scope | None) =>
    match src_file.scope
    | let scope: Scope =>
      scope
    else
      let scope_path = FilePath(_auth, _scope_path(src_file))
      match OpenFile(scope_path)
      | let file: File =>
        let json_str = recover val file.read_string(file.size()) end
        match recover val json.Parse(json_str) end
        | let obj: json.Object val =>
          match recover val ParseScopeJson(obj, None) end
          | let scope: Scope val =>
            _log(Fine) and _log.log(
              src_file.task_id.string() + ": loaded " + scope_path.path)
            src_file.scope = scope
            src_file.make_indices()
            return scope
          | let err: String =>
            _log(Error) and _log.log(
              src_file.task_id.string() + ": error loading " + scope_path.path +
              err)
          end
        | let item: json.Item val =>
          _log(Error) and _log.log(
            src_file.task_id.string() + ": error loading " + scope_path.path +
            ": a scope file must be an object")
        | let err: json.ParseError =>
          _log(Error) and _log.log(
            src_file.task_id.string() + ": error loading " + scope_path.path +
            ":" + err.index.string() + ": " + err.message)
        end
      else
        _log(Error) and _log.log(
          src_file.task_id.string() + ": error opening " + scope_path.path)
      end
      None
    end

  be scoped_file(
    task_id: USize,
    canonical_path: String,
    syntax_tree: ast.Node,
    scope: Scope val)
  =>
    match try _src_items(canonical_path)? end
    | let src_file: SrcFileItem =>
      if src_file.task_id != task_id then
        _log(Fine) and _log.log(
          task_id.string() + ": abandoning scope for " + canonical_path +
            "; src_file is newer: " + src_file.task_id.string())
        return
      end

      _log(Fine) and _log.log(
        task_id.string() + ": scoped " + canonical_path)

      src_file.syntax_tree = syntax_tree
      src_file.scope = scope
      src_file.make_indices()

      _write_syntax_tree(src_file)
      _write_scope(src_file)

      //_process_imports(canonical_path, scope')

      _log(Fine) and _log.log(
        task_id.string() + ": " + canonical_path + " => Linting")

      src_file.state = AnalysisLinting
      _src_item_queue.push(src_file)
      _process_src_item_queue()
    else
      _log(Error) and _log.log(
        task_id.string() + ": scoped unknown file " + canonical_path)
    end

  // fun ref _process_imports(canonical_path: String, scope: Scope) =>
  //   (let base_path, _) = Path.split(scope.name)

  //   var i: USize = 0
  //   while i < scope.imports.size() do
  //     try
  //       (let alias, let import_path) = scope.imports(i)?
  //       match _try_analyze_import(base_path, import_path)
  //       | let canonical_import_path: String =>
  //         try scope.imports.update(i, (alias, canonical_import_path))? end
  //         i = i + 1
  //         continue
  //       else
  //         var found = false
  //         for pp in _pony_path.values() do
  //           match _try_analyze_import(pp.path, import_path)
  //           | let canonical_import_path: String =>
  //             try scope.imports.update(i, (alias, canonical_import_path))? end
  //             found = true
  //             break
  //           end
  //         end

  //         if found then
  //           i = i + 1
  //           continue
  //         else
  //           match _pony_packages_path
  //           | let ppp: FilePath =>
  //             match _try_analyze_import(ppp.path, import_path)
  //             | let canonical_import_path: String =>
  //               try scope.imports.update(i, (alias, canonical_import_path))? end
  //               i = i + 1
  //               continue
  //             end
  //           end
  //         end
  //       end
  //       _log(Error) and _log.log(
  //         "unable to resolve package " + import_path + " for " + canonical_path)
  //     end
  //     i = i + 1
  //   end

  // fun ref _try_analyze_import(base_path: String, import_path: String)
  //   : (String | None)
  // =>
  //   let combined_path = FilePath(_auth, Path.join(base_path, import_path))
  //   if combined_path.exists() then
  //     let canonical_path =
  //       try
  //         combined_path.canonical()?
  //       else
  //         combined_path
  //       end
  //     if not _src_items.contains(canonical_path.path) then
  //       analyze(_get_next_task_id(), canonical_path.path)
  //     else
  //       _log(Fine) and _log.log(
  //         "not analyzing existing import " + canonical_path.path)
  //     end
  //     return canonical_path.path
  //   end

  be scope_failed(
    task_id: USize,
    canonical_path: String,
    errors: ReadSeq[ast.TraverseError] val)
  =>
    match try _src_items(canonical_path)? end
    | let src_file: SrcFileItem =>
      if src_file.task_id != task_id then
        _log(Fine) and _log.log(
          task_id.string() + ": ignoring failed scope for " + canonical_path +
            "; src_file is newer: " + src_file.task_id.string())
        return
      end

      for (node, message) in errors.values() do
        _log(Error) and _log.log(
          src_file.task_id.string() + ": scope error: " + message)
        let si = node.src_info()
        match (si.line, si.column, si.next_line, si.next_column)
        | (let l: USize, let c: USize, let nl: USize, let nc: USize) =>
          _push_error(
            _analyze_errors,
            AnalyzerError(
              canonical_path, AnalyzeError, message, l, c, nl, nc))
        else
          _push_error(
            _analyze_errors,
            AnalyzerError(canonical_path, AnalyzeError, message))
        end
      end
      src_file.state = AnalysisError
    else
      _log(Error) and _log.log(task_id.string() + ": failed to scope unknown " +
        canonical_path)
    end

  fun ref _write_scope(src_file: SrcFileItem) =>
    _log(Fine) and _log.log(
      src_file.task_id.string() + ": writing scope file for " +
      src_file.canonical_path)

    let scope =
      match src_file.scope
      | let scope': Scope val =>
        scope'
      else
        _log(Error) and _log.log(
          src_file.task_id.string() + ": no scope for " +
            src_file.canonical_path)
        return
      end

    let scope_path = _scope_path(src_file)
    (let dir, _) = Path.split(scope_path)
    let dir_path = FilePath(_auth, dir)
    if (not dir_path.exists()) and (not dir_path.mkdir()) then
      _log(Error) and _log.log(
        src_file.task_id.string() + "unable to create directory " +
        dir_path.path)
      _push_error(_workspace_errors, AnalyzerError(
        dir_path.path, AnalyzeError, "unable to create storage directory"))
    end

    match CreateFile(FilePath(_auth, scope_path))
    | let file: File =>
      file.set_length(0)
      let json_item = scope.get_json()
      let json_str =
        ifdef debug then
          json_item.get_string(true)
        else
          json_item.get_string(false)
        end
      _log(Fine) and _log.log(
        src_file.task_id.string() + ": writing " + scope_path)
      if not file.write(consume json_str) then
        _log(Error) and _log.log(
          src_file.task_id.string() + ": unable to write scope file " +
          scope_path)
        _push_error(_workspace_errors, AnalyzerError(
          src_file.canonical_path,
          AnalyzeError,
          "unable to write scope file" + scope_path))
      end
    else
      _log(Error) and _log.log(
        src_file.task_id.string() + ": unable to create scope file " +
        scope_path)
      _push_error(_workspace_errors, AnalyzerError(
        src_file.canonical_path,
        AnalyzeError,
        "unable to create syntax tree file" + scope_path))
    end

  fun ref _lint(src_file: SrcFileItem) =>
    if _disposing then return end

    _log(Fine) and _log.log(
      src_file.task_id.string() + ": linting " + src_file.canonical_path)

    let syntax_tree =
      match _get_syntax_tree(src_file)
      | let node: ast.Node =>
        node
      else
        _log(Error) and _log.log(
          src_file.task_id.string() + ": unable to get syntax tree for " +
            src_file.canonical_path)
        src_file.state = AnalysisError
        return
      end

    src_file.state = AnalysisLinting
    let config = _get_lint_config(src_file)
    let canonical_path = src_file.canonical_path
    let self: EohippusAnalyzer = this
    let lint = linter.Linter(
      config,
      object tag is linter.LinterNotify
        be lint_completed(
          lint': linter.Linter,
          task_id': USize,
          tree': ast.Node,
          issues': ReadSeq[linter.Issue] val,
          errors': ReadSeq[ast.TraverseError] val)
        =>
          self._linted_file(task_id', canonical_path, issues', errors')

        be linter_failed(task_id': USize, message': String) =>
          self._lint_failed(task_id', canonical_path, message')
      end)
    lint.lint(src_file.task_id, syntax_tree)

  be _linted_file(
    task_id: USize,
    canonical_path: String,
    issues: ReadSeq[linter.Issue] val,
    errors: ReadSeq[ast.TraverseError] val)
  =>
    if _disposing then return end
    match try _src_items(canonical_path)? end
    | let src_file: SrcFileItem =>
      if src_file.task_id != task_id then
        _log(Fine) and _log.log(
          task_id.string() + ": abandoning lint for " + canonical_path +
            "; src_file is newer: " + src_file.task_id.string())
        return
      end

      _log(Fine) and _log.log(
        task_id.string() + ": linted " + canonical_path + "; " +
        issues.size().string() + " issues, " + errors.size().string() +
        " errors")

      for issue in issues.values() do
        try
          let start = issue.start.head()?.src_info()
          let next = issue.next.head()?.src_info()
          match (start.line, start.column, next.line, next.column)
          | (let l: USize, let c: USize, let nl: USize, let nc: USize) =>
            _push_error(_lint_errors, AnalyzerError(
              canonical_path,
              AnalyzeWarning,
              issue.rule.message(),
              l,
              c,
              nl,
              nc))
          end
        end
      end
      for (node, message) in errors.values() do
        let si = node.src_info()
        match (si.line, si.column, si.next_line, si.next_column)
        | (let l: USize, let c: USize, let nl: USize, let nc: USize) =>
          _push_error(_lint_errors, AnalyzerError(
            canonical_path, AnalyzeError, message, l, c, nl, nc))
        end
      end

      _log(Fine) and _log.log(
        src_file.task_id.string() + ": " + src_file.canonical_path +
        " => UpToDate")

      src_file.state = AnalysisUpToDate
      _src_item_queue.push(src_file)
      _process_src_item_queue()
    else
      _log(Error) and _log.log(
        task_id.string() + ": linted unknown file " + canonical_path)
    end

  be _lint_failed(task_id: USize, canonical_path: String, message: String) =>
    if _disposing then return end
    match try _src_items(canonical_path)? end
    | let src_file: SrcFileItem =>
      if src_file.task_id != task_id then
        _log(Fine) and _log.log(
          task_id.string() + ": ignoring failed lint for " + canonical_path +
            "; src_file is newer: " + src_file.task_id.string())
        return
      end

      _log(Error) and _log.log(
        task_id.string() + ": lint failed for " + canonical_path + ": " +
          message)

      _push_error(_lint_errors, AnalyzerError(
        canonical_path, AnalyzeError, "lint failed: " + message))
      src_file.state = AnalysisError
    else
      _log(Error) and _log.log(
        task_id.string() + ": failed to lint unknown file " + canonical_path)
    end

  fun ref _get_lint_config(src_file: SrcFileItem): linter.Config val =>
    var cur_path = src_file.canonical_path
    repeat
      (var dir_path, _) = Path.split(cur_path)
      try
        return _lint_configs(dir_path)?
      else
        let editor_config_path = Path.join(dir_path, ".editorconfig")
        let config_file_path = FilePath(_auth, editor_config_path)
        if config_file_path.exists() then
          match linter.EditorConfig.read(config_file_path)
          | let config: linter.Config val =>
            _log(Fine) and _log.log(
              src_file.task_id.string() + ": found .editorconfig " +
                config_file_path.path)
            _lint_configs.update(dir_path, config)
            return config
          | let err: String =>
            _log(Error) and _log.log(
              src_file.task_id.string() + ": unable to read " +
                config_file_path.path)
          end
        elseif
          try
            (dir_path == "") or
            (dir_path == "/") or
            ((dir_path.size() == 3) and (dir_path(1)? == ':'))
          else
            false
          end
        then
          break
        end
        cur_path = dir_path
      end
    until false end
    linter.EditorConfig.default()

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

  fun _syntax_tree_path(src_file: SrcFileItem box): String =>
    src_file.storage_prefix + ".syntax.json"

  fun _scope_path(src_file: SrcFileItem box): String =>
    src_file.storage_prefix + ".scope.json"
