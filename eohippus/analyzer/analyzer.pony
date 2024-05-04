use "files"

use ast = "../ast"
use parser = "../parser"

interface Analyzer
  be analyze(task_id: USize, canonical_path: String)

  be open_file(task_id: USize, canonical_path: String, parse: parser.Parser)

  be close_file(task_id: USize, canonical_path: String)

  be report_errors(task_id: USize)

actor EohippusAnalyzer is Analyzer
  let _auth: FileAuth
  let _workspace: (FilePath | None)
  let _storage_path: (FilePath | None)
  let _pony_path: ReadSeq[FilePath]
  let _pony_executable: (FilePath | None)
  let _pony_builtin_path: (FilePath | None)
  let _grammar: parser.NamedRule
  let _listener: AnalyzerListener

  let _errors: Array[AnalyzerError] iso = Array[AnalyzerError]

  new create(
    auth: FileAuth,
    workspace: (FilePath | None),
    storage_path: (FilePath | None),
    pony_path: ReadSeq[FilePath] val,
    ponyc_executable: (FilePath | None),
    pony_builtin_path: (FilePath | None),
    grammar: parser.NamedRule,
    listener: AnalyzerListener)
  =>
    _auth = auth
    _workspace = workspace
    _pony_path = pony_path
    _ponyc_executable = ponyc_executable
    _pony_builtin_path = pony_builtin_path
    _grammar = grammar
    _listener = listener

    match _workspace
    | let fp: FilePath =>
      let ws =
        match try fp.canonical() end
        | let fp': FilePath =>
          _workspace = fp'
          fp'
        else
          fp
        end

      try
        let info = FileInfo(ws)?
        if not info.directory then
          _errors.push(AnalyzerError(
            ws.path, 0, 0, "workspace is not a directory"))
          _workspace = None
        end
      else
        _errors.push(AnalyzerError(
          ws.path, 0, 0, "workspace directory does not exist"))
        _workspace = None
      end
    end

    match _storage_path
    | let fp: FilePath =>
      let sp =
        match try fp.canonical() end
        | let fp': FilePath =>
          _storage_path = fp'
          fp'
        else
          fp
        end

      try
        let info = FileInfo(sp)?
        if not info.directory then
          _errors.push(AnalyzerError(
            sp.path, 0, 0, "storage path is not a directory"))
          _storage_path = None
        end
      else
        _errors.push(AnalyzerError(
          sp.path, 0, 0, "storage path does not exist"))
        _storage_path = None
      end
    else
      match _workspace
      | let fp: FilePath =>
        let sp = fp.join(".eohippus")
        if (not sp.exists() and not sp.mkdir()) then
          _errors.push(AnalyzerError(
            sp.path, 0, 0, "unable to create storage directory"))
          _storage_path = None
        elseif not sp.directory then
          _errors.push(AnalyzerError(
            sp.path, 0, 0, "storage path is not a directory"))
          _storage_path = None
        else
          _storage_path = sp
        end
      end
    end

    match _ponyc_executable
    | let fp: FilePath =>
      let pe =
        match try fp.canonical() end
        | let fp': FilePath =>
          _ponyc_executable = fp'
          fp'
        else
          fp
        end

      try
        let info = FileInfo(pe)
        if not info.file then
          _errors.push(AnalyzerError(
            pe.path, 0, 0, "ponyc executable is not a file"))
          _ponyc_executable = None
        end
      else
        _errors.push(AnalyzerError(
          pe.path, 0, 0, "ponyc executable does not exist"))
      end
    end

  match _pony_builtin_path
  | let fp: FilePath =>
    let pb =
      match try pb.canonical() end
      | let fp': FilePath =>
        _pony_builtin_path = fp'
        fp'
      else
        fp
      end

    try
      let info = FileInfo(pb)
      if not info.directory then
        _errors.push(AnalyzerError(
          pb.path, 0, 0, "pony builtin package path is not a directory"))
        _pony_builtin_path = None
      end
    else
      _errors.push(AnalyzerError(
        pb.path, 0, 0, "pony builtin package path does not exist"))
      _pony_builtin_path = None
    end

  be analyze(task_id: USize, canonical_path: String) =>
    // if we're a directory, traverse it, analyzing pony files
    // if we're a single file
    //   do we have a record in memory
    //     check the timestamp against the physical file
    //       is the physical file is newer, then analyze it
    //
    //   analyze:
    //     if a json ast exists, check the timestamp against the physical file
    //       if the physical file is newer, read it and write json

  be open_file(task_id: USize, canonical_path: String, parse: parser.Parser) =>
    // mark the file as opened, start analyzing the in-memory parse

  be close_file(task_id: USize, canonical_path: String) =>
    // mark the file as closed; write the ast so it's newer than the saved file

  be report_errors(task_id: USize) =>
    _listener.errors_reported(task_id, _errors.clone())
