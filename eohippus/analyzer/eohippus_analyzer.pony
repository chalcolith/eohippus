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

actor EohippusAnalyzer is Analyzer
  let _log: Logger[String]

  let _context: AnalyzerContext
  let _notify: AnalyzerNotify

  let _lint_configs: Map[String, linter.Config val] = _lint_configs.create()

  let _src_items: Map[String, SrcItem] = _src_items.create()
  let _src_item_queue: Array[SrcItem] = _src_item_queue.create()
  var _process_queued: Bool = false

  var _analysis_task_id: USize = 0
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

  var _iteration: USize = 0
  var _disposing: Bool = false

  new create(
    log: Logger[String],
    context: AnalyzerContext,
    notify: AnalyzerNotify)
  =>
    _log = log
    _context = context
    _notify = notify

  fun ref _get_next_task_id(): USize =>
    let result = _analysis_task_id
    _analysis_task_id = _analysis_task_id + 1
    result

  be analyze() =>
    if _disposing then return end

    var task_id = _get_next_task_id()

    let workspace_path = _context.workspace
    let workspace_cache = _context.workspace_cache
    let global_cache = _context.global_cache

    _log(Fine) and _log.log(
      task_id.string() + ": analyzing " + workspace_path.path)

    _src_items.clear()
    _src_items.compact()
    _src_item_queue.clear()
    _src_item_queue.compact()

    _workspace_errors.clear()
    _workspace_errors.compact()
    _parse_errors.clear()
    _parse_errors.compact()
    _lint_errors.clear()
    _lint_errors.compact()
    _analyze_errors.clear()
    _analyze_errors.compact()

    _analyze_dir(task_id, true, workspace_path, workspace_cache, _schedule(0))

    // var schedule = _schedule(250)
    // for pony_path in _context.pony_path_dirs.values() do
    //   try
    //     let info = FileInfo(pony_path)?
    //     if info.directory then
    //       task_id = _get_next_task_id()
    //       _analyze_dir(task_id, false, pony_path, global_cache, schedule)
    //     end
    //   end
    // end

    // schedule = _schedule(500)
    // match _context.pony_packages_path
    // | let pony_packages_path: FilePath =>
    //   task_id = _get_next_task_id()
    //   _analyze_dir(task_id, false, pony_packages_path, global_cache, schedule)
    // end

  be _analyze_dir(
    task_id: USize,
    is_workspace: Bool,
    src_path: FilePath,
    cache_path: FilePath,
    schedule: (I64, I64))
  =>
    try
      let info = FileInfo(src_path)?
      if info.directory then
        src_path.walk(
          this~_walk_dir(task_id, is_workspace, cache_path, schedule))
      else
        _log(Error) and _log.log(
          task_id.string() + ": " + src_path.path + ": not a directory")
      end
    else
      _log(Error) and _log.log(
        task_id.string() + ": " + src_path.path + ": does not exist")
    end

  fun ref _walk_dir(
    task_id: USize,
    is_workspace: Bool,
    cache_path: FilePath,
    schedule: (I64, I64),
    dir_path: FilePath,
    entries: Array[String])
  =>
    // skip directories starting with '.'
    let to_remove = Array[USize]
    for (i, entry) in entries.pairs() do
      try
        if entry(0)? == '.' then
          to_remove.unshift(i)
        end
      end
    end
    for index in to_remove.values() do
      entries.remove(index, 1)
    end

    // skip directories without Pony source files
    var has_pony_source = false
    for entry in entries.values() do
      if _is_pony_file(entry) then
        has_pony_source = true
        break
      end
    end
    if not has_pony_source then
      return
    end

    // enqueue package item
    let package_path = dir_path
    if _src_items.contains(package_path.path) then
      return
    end

    let package = SrcPackageItem(package_path, cache_path)
    package.task_id = task_id
    package.is_workspace = is_workspace

    _log(Fine) and _log.log(
      task_id.string() + ": enqueueing package " + package_path.path)

    // enqueue source file items
    for entry in entries.values() do
      if _is_pony_file(entry) then
        try
          let file_path = dir_path.join(entry)?
          if _src_items.contains(file_path.path) then
            continue
          end

          let src_file = SrcFileItem(file_path, cache_path)
          src_file.task_id = task_id
          src_file.parent_package = package
          src_file.schedule = schedule
          _src_items.update(file_path.path, src_file)
          _enqueue_src_item(src_file)
          package.dependencies.push(src_file)

          _log(Fine) and _log.log(
            task_id.string() + ": enqueueing file " +
            src_file.canonical_path.path)
        end
      end
    end

    _src_items.update(package_path.path, package)
    _enqueue_src_item(package)

  fun tag _is_pony_file(fname: String): Bool =>
    let ext_size = ".pony".size()
    if fname.size() <= ext_size then
      return false
    end
    let index = ISize.from[USize](fname.size() - ext_size)
    fname.compare_sub(
      ".pony", ext_size, index where ignore_case = true) is Equal

  be open_file(
    task_id: USize,
    canonical_path: FilePath,
    parse: parser.Parser)
  =>
    if _disposing then return end
    _log(Fine) and _log.log(
      task_id.string() + ": opening " + canonical_path.path)
    match try _src_items(canonical_path.path)? end
    | let src_file: SrcFileItem =>
      src_file.task_id = task_id
      src_file.state = AnalysisStart
      src_file.schedule = _schedule(0)
      src_file.is_open = true
      src_file.parse = parse
      _enqueue_src_item(src_file)
    else
      let src_file = SrcFileItem(
        canonical_path, _context.get_cache(canonical_path))
      src_file.task_id = task_id
      src_file.state = AnalysisStart
      src_file.is_open = true
      src_file.schedule = _schedule(0)
      src_file.parse = parse
      _src_items.update(canonical_path.path, src_file)
      _enqueue_src_item(src_file)
    end

  be update_file(
    task_id: USize,
    canonical_path: FilePath,
    parse: parser.Parser)
  =>
    if _disposing then return end
    _log(Fine) and _log.log(
      task_id.string() + ": updating " + canonical_path.path)
    match try _src_items(canonical_path.path)? end
    | let src_file: SrcFileItem =>
      src_file.task_id = task_id
      src_file.schedule = _schedule(300)
      src_file.is_open = true
      src_file.parse = parse
      _log(Fine) and _log.log(task_id.string() + ": found in-memory file")
      _enqueue_src_item(src_file, AnalysisStart)
    else
      let src_file = SrcFileItem(
        canonical_path, _context.get_cache(canonical_path))
      src_file.task_id = task_id
      src_file.is_open = true
      src_file.schedule = _schedule(300)
      src_file.parse = parse
      _src_items.update(canonical_path.path, src_file)
      _enqueue_src_item(src_file, AnalysisStart)
      _log(Fine) and _log.log(
        task_id.string() + ": in-memory file not found; creating")
    end

  be close_file(task_id: USize, canonical_path: FilePath) =>
    match try _src_items(canonical_path.path)? end
    | let src_file: SrcFileItem =>
      src_file.is_open = false
    end

  be request_info(
    task_id: USize,
    canonical_path: FilePath,
    notify: AnalyzerRequestNotify)
  =>
    if _disposing then return end

    _log(Fine) and _log.log(
      task_id.string() + ": request " + canonical_path.path)

    if not _src_items.contains(canonical_path.path) then
      let file_dir = Path.split(canonical_path.path)._1
      _analyze_dir(
        task_id,
        false,
        FilePath(_context.file_auth, file_dir),
        _context.get_cache(canonical_path),
        _schedule(0))
    end

    let notifys =
      match try _pending_requests(canonical_path.path)? end
      | let notifys': MapIs[AnalyzerRequestNotify, Set[USize]] =>
        notifys'
      else
        let notifys' = MapIs[AnalyzerRequestNotify, Set[USize]]
        _pending_requests.update(canonical_path.path, notifys')
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
      match try errors(new_error.canonical_path.path)? end
      | let arr': Array[AnalyzerError] =>
        arr'
      else
        let arr' = Array[AnalyzerError]
        errors(new_error.canonical_path.path) = arr'
        arr'
      end
    arr.push(new_error)

  fun ref _clear_errors(
    canonical_path: FilePath,
    errors: Map[String, Array[AnalyzerError]])
  =>
    try
      errors.remove(canonical_path.path)?
      errors.compact()
    end

  fun ref _clear_and_push(
    canonical_path: FilePath,
    errors: Map[String, Array[AnalyzerError]],
    new_error: AnalyzerError)
  =>
    let arr =
      match try errors(new_error.canonical_path.path)? end
      | let arr': Array[AnalyzerError] =>
        arr'.clear()
        arr'
      else
        let arr' = Array[AnalyzerError]
        errors(new_error.canonical_path.path) = arr'
        arr'
      end
    arr.push(new_error)

  fun _collect_errors(
    errors: Map[String, Array[AnalyzerError]],
    canonical_path: (FilePath | None) = None)
    : Array[AnalyzerError] val
  =>
    let result: Array[AnalyzerError] trn = Array[AnalyzerError]
    match canonical_path
    | let key: FilePath =>
      try
        for err in errors(key.path)?.values() do
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

  fun ref _enqueue_src_item(
    src_item: SrcItem,
    new_state: (SrcItemState | None) = None)
  =>
    match new_state
    | let new_state': SrcItemState =>
      src_item.set_state(new_state')
    end

    _src_item_queue.push(src_item)
    _process_src_item_queue()

  fun ref _process_src_item_queue() =>
    if not _process_queued then
      _process_queued = true
      _process_src_item_queue_aux()
    end

  be _process_src_item_queue_aux() =>
    _process_queued = false

    if _disposing then return end

    // if (_iteration % 500) == 0 then
    //   _log_src_item_queue()
    // end
    _iteration = _iteration + 1

    try
      match _src_item_queue.shift()?
      | let file_item: SrcFileItem =>
        _process_file_item(file_item)
      | let package_item: SrcPackageItem =>
        _process_package_item(package_item)
      end
    end

    _process_pending_requests()

    if _src_item_queue.size() > 0 then
      _process_src_item_queue()
    end

  fun ref _log_src_item_queue() =>
    _log(Fine) and _log.log(
      "PACKAGE ITEMS: " + _get_item_stats(_src_items.values(), true))
    _log(Fine) and _log.log(
      "PACKAGE QUEUE: " + _get_item_stats(_src_item_queue.values(), true))
    _log(Fine) and _log.log(
      "FILE ITEMS:    " + _get_item_stats(_src_items.values(), false))
    _log(Fine) and _log.log(
      "FILE QUEUE:    " + _get_item_stats(_src_item_queue.values(), false))

  fun _get_item_stats(iter: Iterator[SrcItem], is_pkg: Bool): String =>
    var num_starting: USize = 0
    var num_parsing: USize = 0
    var num_scoping: USize = 0
    var num_linting: USize = 0
    var num_error: USize = 0
    var num_up_to_date: USize = 0

    for item in iter do
      match item
      | let pkg: SrcPackageItem =>
        if not is_pkg then continue end
      else
        if is_pkg then continue end
      end

      match item.get_state()
      | AnalysisStart =>
        num_starting = num_starting + 1
      | AnalysisParse =>
        num_parsing = num_parsing + 1
      | AnalysisScope =>
        num_scoping = num_scoping + 1
      | AnalysisLint =>
        num_linting = num_linting + 1
      | AnalysisError =>
        num_error = num_error + 1
      | AnalysisUpToDate =>
        num_up_to_date = num_up_to_date + 1
      end
    end
    let str: String trn = String
    str.append("start ")
    str.append(num_starting.string())
    str.append(", parse ")
    str.append(num_parsing.string())
    str.append(", scope ")
    str.append(num_scoping.string())
    str.append(", lint ")
    str.append(num_linting.string())
    str.append(", error ")
    str.append(num_error.string())
    str.append(", done ")
    str.append(num_up_to_date.string())
    consume str

  fun ref _process_package_item(package_item: SrcPackageItem) =>
    // count things
    var num_starting: USize = 0
    var num_parsing: USize = 0
    var num_scoping: USize = 0
    var num_linting: USize = 0
    var num_error: USize = 0
    var num_up_to_date: USize = 0

    for dep in package_item.dependencies.values() do
      match dep.get_state()
      | AnalysisStart =>
        num_starting = num_starting + 1
      | AnalysisParse =>
        num_parsing = num_parsing + 1
      | AnalysisScope =>
        num_scoping = num_scoping + 1
      | AnalysisLint =>
        num_linting = num_linting + 1
      | AnalysisError =>
        num_error = num_error + 1
      | AnalysisUpToDate =>
        num_up_to_date = num_up_to_date + 1
      end
    end

    if num_error > 0 then
      _log(Error) and _log.log(
        package_item.task_id.string() + ": PACKAGE ERROR: " +
        package_item.canonical_path.path)

      package_item.state = AnalysisError

      if package_item.is_workspace then
        _log(Fine) and _log.log(
          package_item.task_id.string() + ": workspace ERROR; notifying")
        _notify_workspace(package_item)
      end
    elseif num_up_to_date == package_item.dependencies.size() then
      _log(Fine) and _log.log(
        package_item.task_id.string() + ": package up to date: " +
        package_item.canonical_path.path)

      package_item.state = AnalysisUpToDate

      if package_item.is_workspace then
        _log(Fine) and _log.log(
          package_item.task_id.string() + ": workspace up to date; notifying")
        _notify_workspace(package_item)
      end
    else
      var new_state = package_item.state
      if num_starting == 0 then
        if num_parsing > 0 then
          new_state = AnalysisParse
        elseif num_scoping > 0 then
          new_state = AnalysisScope
        elseif num_linting > 0 then
          new_state = AnalysisLint
        end
      end

      if new_state isnt package_item.state then
        _log_src_item_queue()
      end

      // if (_iteration % 100) == 0 then
      //   _log(Fine) and _log.log(
      //     package_item.task_id.string() + ": workspace in progress")
      // end

      _enqueue_src_item(package_item, new_state)
    end

  fun ref _notify_workspace(package_item: SrcPackageItem) =>
    _notify.analyzed_workspace(
      this,
      package_item.task_id,
      _collect_errors(_workspace_errors),
      _collect_errors(_parse_errors),
      _collect_errors(_lint_errors),
      _collect_errors(_analyze_errors))

  fun ref _process_file_item(src_file: SrcFileItem) =>
    var needs_push = false
    match src_file.state
    | AnalysisStart =>
      src_file.cache_prefix = _cache_prefix(src_file)

      try _workspace_errors.remove(src_file.canonical_path.path)? end
      try _parse_errors.remove(src_file.canonical_path.path)? end
      try _lint_errors.remove(src_file.canonical_path.path)? end
      try _analyze_errors.remove(src_file.canonical_path.path)? end

      if _is_due(src_file.schedule) then
        src_file.state = AnalysisParse
      end

      if src_file.state is AnalysisParse then
        _log(Fine) and _log.log(
          src_file.task_id.string() + ": " + src_file.canonical_path.path +
          " => Parsing")
      end
      needs_push = true
    | AnalysisParse =>
      if src_file.is_open then
        _parse_open_file(src_file)
      else
        _parse_disk_file(src_file)
      end
    | AnalysisScope =>
      _scope(src_file)
    | AnalysisLint =>
      _lint(src_file)
    | AnalysisError =>
      var errors: Array[AnalyzerError] trn = Array[AnalyzerError]
      try
        for err in _workspace_errors(src_file.canonical_path.path)?.values() do
          errors.push(err)
        end
      end
      try
        for err in _parse_errors(src_file.canonical_path.path)?.values() do
          errors.push(err)
        end
      end
      try
        for err in _lint_errors(src_file.canonical_path.path)?.values() do
          errors.push(err)
        end
      end
      try
        for err in _analyze_errors(src_file.canonical_path.path)?.values() do
          errors.push(err)
        end
      end
      let errors': Array[AnalyzerError] val = consume errors
      _notify.analyze_failed(
        this,
        src_file.task_id,
        src_file.canonical_path,
        errors')

      // try to free up some memory
      if not src_file.is_open then
        src_file.compact()
      end
    | AnalysisUpToDate =>
      _log(Fine) and _log.log(
        src_file.task_id.string() + ": file up to date: " +
        src_file.canonical_path.path)

      _notify.analyzed_file(
        this,
        src_file.task_id,
        src_file.canonical_path,
        src_file.syntax_tree,
        None,
        _collect_errors(_parse_errors),
        _collect_errors(_lint_errors),
        _collect_errors(_analyze_errors))

      // try to free up some memory
      if not src_file.is_open then
        src_file.compact()
      end
    end
    if needs_push then
      _enqueue_src_item(src_file)
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
          .all({(pi) => pi.get_state()() is AnalysisUpToDate()})
        if up_to_date then
          _pending_request_succeeded(package_item, notifys)
          paths_done.push(canonical_path)
        else
          let any_errors = Iter[SrcItem](package_item.dependencies.values())
            .any({(pi) => pi.get_state()() is AnalysisError()})
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
      match (file_item.syntax_tree, file_item.nodes_by_index, file_item.scope)
      |
        (let st: ast.Node, let nbi: Map[USize, ast.Node] val, let sc: Scope val)
      =>
        for (notify, task_ids) in notifys.pairs() do
          for task_id in task_ids.values() do
            _log(Fine) and _log.log(
              task_id.string() + ": request succeeded: "
              + file_item.canonical_path.path)
            notify.request_succeeded(
              task_id, file_item.canonical_path, st, nbi, sc)
          end
        end
      end
    | let package_item: SrcPackageItem =>
      let package_scope: Scope trn = Scope(
        PackageScope,
        package_item.canonical_path.path,
        package_item.canonical_path,
        (0, 0, USize.max_value(), USize.max_value()),
        USize.max_value())

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
            + package_item.canonical_path.path)
          notify.request_succeeded(
            task_id,
            package_item.canonical_path,
            None,
            Map[USize, ast.Node],
            package_scope')
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
          task_id.string() + ": request failed: " +
          src_item.get_canonical_path().path)
        notify.request_failed(
          task_id, src_item.get_canonical_path(), "analysis failed")
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
      src_file.canonical_path.path)

    let task_id = src_file.task_id
    let canonical_path = src_file.canonical_path
    match src_file.parse
    | let parse': parser.Parser =>
      _parse(task_id, canonical_path, parse')
    else
      _log(Error) and _log.log(
        task_id.string() + ": parse failed for " + canonical_path.path +
        "; no data")
    end

  fun ref _parse_disk_file(src_file: SrcFileItem) =>
    if _disposing then return end

    _log(Fine) and _log.log(
      src_file.task_id.string() + ": parsing on disk " +
      src_file.canonical_path.path)

    let src_file_path = src_file.canonical_path
    let syntax_tree_path = _syntax_tree_path(src_file)
    if
      syntax_tree_path.exists() and
      (not _source_is_newer(src_file_path, syntax_tree_path))
    then
      _log(Fine) and _log.log(
        src_file.task_id.string() + ": cache is newer; not parsing " +
        src_file.canonical_path.path)

      match _get_syntax_tree(src_file)
      | let syntax_tree: ast.Node =>
        _collect_error_sections(src_file.canonical_path, syntax_tree)
        src_file.syntax_tree = syntax_tree
      else
        _log(Error) and _log.log(
          src_file.task_id.string() + ": unable to load syntax for " +
          src_file.canonical_path.path)
        return
      end

      _enqueue_src_item(src_file, AnalysisScope)
      return
    end

    let task_id = src_file.task_id
    let canonical_path = src_file.canonical_path
    match OpenFile(src_file.canonical_path)
    | let file: File ref =>
      let source = file.read(file.size())
      let segments: Array[ReadSeq[U8] val] val =
        [ as ReadSeq[U8] val: consume source ]
      let parse = parser.Parser(segments)
      _parse(task_id, canonical_path, parse)
    else
      _log(Error) and _log.log("unable to read " + canonical_path.path)
      _push_error(_workspace_errors, AnalyzerError(
        canonical_path, AnalyzeError, "unable to read file"))
      _enqueue_src_item(src_file, AnalysisError)
    end

  fun ref _parse(
    task_id: USize,
    canonical_path: FilePath,
    parse: parser.Parser)
  =>
    if _disposing then return end

    // _log(Fine) and _log.log(
    //   task_id.string() + ": parsing " + canonical_path.path)
    let self: EohippusAnalyzer tag = this
    parse.parse(
      _context.grammar,
      parser.Data(canonical_path.path),
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
                task_id.string() + ": " + canonical_path.path +
                  ": root node was not SrcFile")
              self._parse_failed(
                task_id, canonical_path, "root node was not SrcFile")
            end
          else
            _log(Error) and _log.log(
              task_id.string() + ": " + canonical_path.path +
              ": failed to get SrcFile node")
            self._parse_failed(
              task_id, canonical_path, "failed to get SrcFile node")
          end
        | let failure: parser.Failure =>
          _log(Error) and _log.log(
            task_id.string() + ": " + canonical_path.path + ": " +
            failure.get_message())
          self._parse_failed(task_id, canonical_path, failure.get_message())
        end
      })

  fun ref _collect_error_sections(canonical_path: FilePath, node: ast.Node) =>
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
    canonical_path: FilePath,
    node: ast.NodeWith[ast.SrcFile])
  =>
    if _disposing then return end
    _process_src_item_queue()

    match try _src_items(canonical_path.path)? end
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
            task_id.string() + ": line error " + canonical_path.path +
            ": " + message)

          let si = n.src_info()
          match (si.line, si.column, si.next_line, si.next_column)
          | (let l: USize, let c: USize, let nl: USize, let nc: USize) =>
            _push_error(
              _parse_errors,
              AnalyzerError(
                canonical_path, AnalyzeError, message, l, c, nl, nc))
          else
            _push_error(
              _parse_errors,
              AnalyzerError(canonical_path, AnalyzeError, message))
          end
        end
        _enqueue_src_item(src_file, AnalysisError)
        return
      end

      src_file.syntax_tree = syntax_tree
      src_file.make_indices()
      _write_syntax_tree(src_file)
      _collect_error_sections(canonical_path, syntax_tree)

      _log(Fine) and _log.log(
        src_file.task_id.string() + ": " + src_file.canonical_path.path +
        " => Scoping")

      _enqueue_src_item(src_file, AnalysisScope)
    else
      _log(Error) and _log.log(
        task_id.string() + ": parsed untracked source file " +
        canonical_path.path)
    end

  be _parse_failed(
    task_id: USize,
    canonical_path: FilePath,
    message: String,
    line: USize = 0,
    column: USize = 0,
    next_line: USize = 0,
    next_column: USize = 0)
  =>
    if _disposing then return end
    _process_src_item_queue()

    match try _src_items(canonical_path.path)? end
    | let src_file: SrcFileItem =>
      if src_file.task_id != task_id then
        _log(Fine) and _log.log(
          task_id.string() + ": ignoring failed parse for " +
          canonical_path.path + "; src_file is newer: " +
          src_file.task_id.string())
        return
      end

      _log(Error) and _log.log(
        task_id.string() + ": parse failed for " + canonical_path.path)

      _push_error(_parse_errors, AnalyzerError(
        canonical_path,
        AnalyzeError,
        message,
        line,
        column,
        next_line,
        next_column))

      let error_section = ast.NodeWith[ast.ErrorSection](
        ast.SrcInfo(canonical_path.path), [], ast.ErrorSection(message))
      let node = ast.NodeWith[ast.SrcFile](
        ast.SrcInfo(canonical_path.path),
        [ error_section ],
        ast.SrcFile(canonical_path.path, [], []))
      _write_syntax_tree(src_file, node)

      _log(Fine) and _log.log(
        src_file.task_id.string() + ": " + src_file.canonical_path.path +
        " => Error")

      _enqueue_src_item(src_file, AnalysisError)
    end

  fun ref _write_syntax_tree(
    src_file: SrcFileItem,
    syntax_tree: (ast.Node | None) = None)
  =>
    _log(Fine) and _log.log(
      src_file.task_id.string() + ": writing syntax tree for " +
      src_file.canonical_path.path)

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
    let dir_path = FilePath(
      _context.file_auth, Path.split(syntax_tree_path.path)._1)
    if (not dir_path.exists()) and (not dir_path.mkdir()) then
      _log(Error) and _log.log("unable to create directory " + dir_path.path)
      _push_error(_workspace_errors, AnalyzerError(
        dir_path, AnalyzeError, "unable to create storage directory"))
      return
    end

    match CreateFile(syntax_tree_path)
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
        src_file.task_id.string() + ": writing " + syntax_tree_path.path)
      if not file.write(consume json_str) then
        _log(Error) and _log.log(
          src_file.task_id.string() + ": unable to write syntax tree file " +
          syntax_tree_path.path)
        _push_error(_workspace_errors, AnalyzerError(
          src_file.canonical_path,
          AnalyzeError,
          "unable to write syntax tree file" + syntax_tree_path.path))
      end
    else
      _log(Error) and _log.log(
        src_file.canonical_path.path + ": unable to create syntax tree file " +
        syntax_tree_path.path)
      _push_error(_workspace_errors, AnalyzerError(
        src_file.canonical_path,
        AnalyzeError,
        "unable to create syntax tree file " + syntax_tree_path.path))
    end

  fun ref _get_syntax_tree(src_file: SrcFileItem): (ast.Node | None) =>
    match src_file.syntax_tree
    | let node: ast.Node =>
      node
    else
      let syntax_path = _syntax_tree_path(src_file)
      match OpenFile(syntax_path)
      | let file: File =>
        let json_str = recover val file.read_string(file.size()) end
        match json.Parse(json_str)
        | let obj: json.Object =>
          match ast.ParseNode(src_file.canonical_path.path, obj)
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
    _process_src_item_queue()

    _log(Fine) and _log.log(
      src_file.task_id.string() + ": scoping " + src_file.canonical_path.path)

    let src_file_path = src_file.canonical_path
    let scope_path = _scope_path(src_file)
    if
      scope_path.exists() and
      (not _source_is_newer(src_file_path, scope_path))
    then
      _log(Fine) and _log.log(
        src_file.task_id.string() + ": cache is newer; not scoping " +
        src_file.canonical_path.path)
      match _get_scope(src_file)
      | let scope: Scope =>
        src_file.scope = scope
        _enqueue_src_item(src_file, AnalysisLint)
        return
      else
        _log(Error) and _log.log(
          src_file.task_id.string() + ": unable to load scope for " +
          src_file.canonical_path.path)
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
        src_file.canonical_path.path)
      _enqueue_src_item(src_file, AnalysisError)
    end

  fun ref _get_scope(src_file: SrcFileItem): (Scope | None) =>
    match src_file.scope
    | let scope: Scope =>
      scope
    else
      let scope_path = _scope_path(src_file)
      match OpenFile(scope_path)
      | let file: File =>
        let json_str = recover val file.read_string(file.size()) end
        match recover val json.Parse(json_str) end
        | let obj: json.Object val =>
          match recover val ParseScopeJson(_context.file_auth, obj, None) end
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
    canonical_path: FilePath,
    syntax_tree: ast.Node,
    scope: Scope val)
  =>
    if _disposing then return end
    _process_src_item_queue()

    match try _src_items(canonical_path.path)? end
    | let src_file: SrcFileItem =>
      if src_file.task_id != task_id then
        _log(Fine) and _log.log(
          task_id.string() + ": abandoning scope for " + canonical_path.path +
          "; src_file is newer: " + src_file.task_id.string())
        return
      end

      _log(Fine) and _log.log(
        task_id.string() + ": scoped " + canonical_path.path)

      src_file.syntax_tree = syntax_tree
      src_file.scope = scope
      src_file.make_indices()

      _write_syntax_tree(src_file)
      _write_scope(src_file)

      //_process_imports(canonical_path, scope')

      _log(Fine) and _log.log(
        task_id.string() + ": " + canonical_path.path + " => Linting")

      _enqueue_src_item(src_file, AnalysisLint)
    else
      _log(Error) and _log.log(
        task_id.string() + ": scoped unknown file " + canonical_path.path)
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
    canonical_path: FilePath,
    errors: ReadSeq[ast.TraverseError] val)
  =>
    if _disposing then return end
    _process_src_item_queue()

    match try _src_items(canonical_path.path)? end
    | let src_file: SrcFileItem =>
      if src_file.task_id != task_id then
        _log(Fine) and _log.log(
          task_id.string() + ": ignoring failed scope for " +
          canonical_path.path + "; src_file is newer: " +
          src_file.task_id.string())
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
      _enqueue_src_item(src_file, AnalysisError)
    else
      _log(Error) and _log.log(task_id.string() + ": failed to scope unknown " +
        canonical_path.path)
    end

  fun ref _write_scope(src_file: SrcFileItem) =>
    _log(Fine) and _log.log(
      src_file.task_id.string() + ": writing scope file for " +
      src_file.canonical_path.path)

    let scope =
      match src_file.scope
      | let scope': Scope val =>
        scope'
      else
        _log(Error) and _log.log(
          src_file.task_id.string() + ": no scope for " +
          src_file.canonical_path.path)
        return
      end

    let scope_path = _scope_path(src_file)
    let dir_path = FilePath(_context.file_auth, Path.split(scope_path.path)._1)
    if (not dir_path.exists()) and (not dir_path.mkdir()) then
      _log(Error) and _log.log(
        src_file.task_id.string() + "unable to create directory " +
        dir_path.path)
      _push_error(_workspace_errors, AnalyzerError(
        dir_path, AnalyzeError, "unable to create cache directory"))
    end

    match CreateFile(scope_path)
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
        src_file.task_id.string() + ": writing " + scope_path.path)
      if not file.write(consume json_str) then
        _log(Error) and _log.log(
          src_file.task_id.string() + ": unable to write scope file " +
          scope_path.path)
        _push_error(_workspace_errors, AnalyzerError(
          src_file.canonical_path,
          AnalyzeError,
          "unable to write scope file" + scope_path.path))
      end
    else
      _log(Error) and _log.log(
        src_file.task_id.string() + ": unable to create scope file " +
        scope_path.path)
      _push_error(_workspace_errors, AnalyzerError(
        src_file.canonical_path,
        AnalyzeError,
        "unable to create syntax tree file" + scope_path.path))
    end

  fun ref _lint(src_file: SrcFileItem) =>
    if _disposing then return end

    _log(Fine) and _log.log(
      src_file.task_id.string() + ": linting " + src_file.canonical_path.path)

    let syntax_tree =
      match _get_syntax_tree(src_file)
      | let node: ast.Node =>
        node
      else
        _log(Error) and _log.log(
          src_file.task_id.string() + ": unable to get syntax tree for " +
          src_file.canonical_path.path)
        _enqueue_src_item(src_file, AnalysisError)
        return
      end

    src_file.state = AnalysisLint
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
    canonical_path: FilePath,
    issues: ReadSeq[linter.Issue] val,
    errors: ReadSeq[ast.TraverseError] val)
  =>
    if _disposing then return end
    _process_src_item_queue()

    match try _src_items(canonical_path.path)? end
    | let src_file: SrcFileItem =>
      if src_file.task_id != task_id then
        _log(Fine) and _log.log(
          task_id.string() + ": abandoning lint for " + canonical_path.path +
            "; src_file is newer: " + src_file.task_id.string())
        return
      end

      _log(Fine) and _log.log(
        task_id.string() + ": linted " + canonical_path.path + "; " +
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
        src_file.task_id.string() + ": " + src_file.canonical_path.path +
        " => UpToDate")
      _enqueue_src_item(src_file, AnalysisUpToDate)
    else
      _log(Error) and _log.log(
        task_id.string() + ": linted unknown file " + canonical_path.path)
    end

  be _lint_failed(task_id: USize, canonical_path: FilePath, message: String) =>
    if _disposing then return end
    _process_src_item_queue()

    match try _src_items(canonical_path.path)? end
    | let src_file: SrcFileItem =>
      if src_file.task_id != task_id then
        _log(Fine) and _log.log(
          task_id.string() + ": ignoring failed lint for " +
          canonical_path.path + "; src_file is newer: " +
          src_file.task_id.string())
        return
      end

      _log(Error) and _log.log(
        task_id.string() + ": lint failed for " + canonical_path.path + ": " +
          message)

      _push_error(_lint_errors, AnalyzerError(
        canonical_path, AnalyzeError, "lint failed: " + message))
      _enqueue_src_item(src_file, AnalysisError)
    else
      _log(Error) and _log.log(
        task_id.string() + ": failed to lint unknown file " +
        canonical_path.path)
    end

  fun ref _get_lint_config(src_file: SrcFileItem): linter.Config val =>
    var cur_path = src_file.canonical_path.path
    repeat
      (var dir_path, _) = Path.split(cur_path)
      try
        return _lint_configs(dir_path)?
      else
        let editor_config_path = Path.join(dir_path, ".editorconfig")
        let config_file_path = FilePath(_context.file_auth, editor_config_path)
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

  fun _cache_prefix(file_item: SrcFileItem): String =>
    let fcp = file_item.canonical_path.path
    let cache_base = Path.split(file_item.cache_path.path)._1

    let comp =
      ifdef windows then
        fcp.compare_sub(cache_base, cache_base.size() where ignore_case = true)
      else
        fcp.compare_sub(cache_base, cache_base.size())
      end

    if comp is Equal then
      let rest = fcp.substring(ISize.from[USize](cache_base.size() + 1))
      Path.join(file_item.cache_path.path, consume rest)
    else
      let rest = fcp.clone() .> replace(":", "_")
      Path.join(file_item.cache_path.path, consume rest)
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

  fun _syntax_tree_path(src_file: SrcFileItem box): FilePath =>
    FilePath(_context.file_auth, src_file.cache_prefix + ".syntax.json")

  fun _scope_path(src_file: SrcFileItem box): FilePath =>
    FilePath(_context.file_auth, src_file.cache_prefix + ".scope.json")
