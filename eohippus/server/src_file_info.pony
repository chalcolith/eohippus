use "files"
use "logger"

use analyzer = "../analyzer"
use ast = "../ast"
use parser = "../parser"
use rpc_data = "rpc/data_types"
use ".."

class SrcFileInfo
  let _log: Logger[String]
  let _server: Server

  let client_uri: String
  let canonical_path: FilePath

  var client_version: I128 = 0
  var analyze_task_id: USize = 0
  var segments: Array[String] = []
  var parse: (parser.Parser | None) = None
  var syntax_tree: (ast.SyntaxTree | None) = None
  var line_beginnings: Array[(USize, USize)] = []

  var parse_errors: Array[analyzer.AnalyzerError] val = []
  var lint_errors: Array[analyzer.AnalyzerError] val = []
  var analyze_errors: Array[analyzer.AnalyzerError] val = []

  new create(
    log: Logger[String],
    auth: FileAuth,
    server: Server,
    client_uri': String)
  =>
    _log = log
    _server = server
    client_uri = client_uri'
    canonical_path = _get_canonical_path(auth, client_uri')

  fun ref did_open(task_id: USize, version: I128, text: String)
    : parser.Parser
  =>
    _log(Fine) and _log.log("starting parse for " + canonical_path.path)
    analyze_task_id = task_id
    client_version = version
    syntax_tree = None
    segments.clear()
    segments.push(text)
    let segments': Array[String] trn = Array[String]
    for segment in segments.values() do
      segments'.push(segment)
    end
    let parse' = parser.Parser(consume segments', {(s) => _log.log(s) })
    parse = parse'
    parse'

  fun ref did_change(
    task_id: USize,
    document: rpc_data.VersionedTextDocumentIdentifier,
    changes: Array[rpc_data.TextDocumentContentChangeEvent] val)
  =>
    //_log(Fine) and _log.log("got " + changes.size().string() + " changes")
    syntax_tree = None
    for change in changes.values() do
      match change.range()
      | let range: rpc_data.Range =>
        // _log(Fine) and _log.log(
        //   "replacing text from " +
        //     range.start().line().string() + ":" +
        //     range.start().character().string() + " - " +
        //     range.endd().line().string() + ":" +
        //     range.endd().character().string() + " with size " +
        //     change.text().size().string())

        (let start_segment, let start_index, let end_segment, let end_index) =
          _get_range_data(range)

        // _log(Fine) and _log.log("  segments " + start_segment.string() + ":" +
        //   start_index.string() + " - " + end_segment.string() + ":" +
        //   end_index.string())
        try
          let prefix: String val = segments(start_segment)?.substring(
            ISize(0), ISize.from[USize](start_index))
          let suffix: String val = segments(end_segment)?.substring(
            ISize.from[USize](end_index))
          // delete old segments
          var i: USize = 0
          while i < ((end_segment - start_segment) + 1) do
            segments.delete(start_segment)?
            match parse
            | let parse': parser.Parser =>
              parse'.remove_segment(start_segment)
            end
            i = i + 1
          end

          // if our chunks are small, combine them
          let change_size = prefix.size() + change.text().size() + suffix.size()
          if change_size < 1024 then
            let new_chunk: String trn = String(change_size)
            new_chunk.append(prefix)
            new_chunk.append(change.text())
            new_chunk.append(suffix)
            let new_chunk': String val = consume new_chunk

            segments.insert(start_segment, new_chunk')?
            match parse
            | let parse': parser.Parser =>
              parse'.insert_segment(start_segment, new_chunk')
            end
          else
            // otherwise, insert prefix then change then suffix
            var insert_pos = start_segment
            if prefix.size() > 0 then
              segments.insert(insert_pos, prefix)?
              match parse
              | let parse': parser.Parser =>
                parse'.insert_segment(insert_pos, prefix)
              end
              insert_pos = insert_pos + 1
            end
            if change.text().size() > 0 then
              segments.insert(insert_pos, change.text())?
              match parse
              | let parse': parser.Parser =>
                parse'.insert_segment(insert_pos, change.text())
              end
              insert_pos = insert_pos + 1
            end
            if suffix.size() > 0 then
              segments.insert(insert_pos, suffix)?
              match parse
              | let parse': parser.Parser =>
                parse'.insert_segment(insert_pos, suffix)
              end
              insert_pos = insert_pos + 1
            end
          end
        end
      else
        _log(Fine) and _log.log("replacing all text")
        // remove all segments and add the new one
        var i: USize = 0
        while i < segments.size() do
          match parse
          | let parse': parser.Parser =>
            parse'.remove_segment(0)
          end
          i = i + 1
        end
        match parse
        | let parse': parser.Parser =>
          parse'.insert_segment(0, change.text())
        end
        segments.clear()
        segments.push(change.text())
      end
      line_beginnings.clear()
    end
    _log(Fine) and _log.log("segments now")
    var i: USize = 0
    for segment in segments.values() do
      _log(Fine) and _log.log("  " + i.string() + " '" + StringUtil.escape(segment) + "'")
      i = i + 1
    end
    _build_line_beginnings()

    client_version = document.version()
    analyze_task_id = task_id

  fun ref _get_range_data(range: rpc_data.Range)
    : (USize, USize, USize, USize)
  =>
    if line_beginnings.size() == 0 then
      _build_line_beginnings()
    end
    var start_segment: USize = 0
    var start_index: USize = 0
    var end_segment: USize = 0
    var end_index: USize = 0
    try
      (var seg, var index) = line_beginnings(
        USize.from[I128](range.start().line()))?
      //_log(Fine) and _log.log("  start line " + seg.string() + ":" + index.string())
      start_segment = seg
      start_index = index + USize.from[I128](range.start().character())
      var cur_size = segments(start_segment)?.size()
      while start_index > cur_size do
        start_segment = start_segment + 1
        start_index = start_index - cur_size
        cur_size = segments(start_segment)?.size()
      end

      (seg, index) = line_beginnings(USize.from[I128](range.endd().line()))?
      //_log(Fine) and _log.log("  end line  " + seg.string() + ":" + index.string())
      end_segment = seg
      end_index = index + USize.from[I128](range.endd().character())
      cur_size = segments(end_segment)?.size()
      while end_index > cur_size do
        end_segment = end_segment + 1
        end_index = end_index - cur_size
        cur_size = segments(end_segment)?.size()
      end
    end
    (start_segment, start_index, end_segment, end_index)

  fun ref _build_line_beginnings() =>
    line_beginnings.clear()
    match syntax_tree
    | let st: ast.SyntaxTree =>
      var seg_index: USize = 0
      for line_pos in st.line_beginnings.values() do
        try
          while segments(seg_index)? isnt line_pos.segment() do
            seg_index = seg_index + 1
          end
          line_beginnings.push((seg_index, line_pos.index()))
        end
      end
    else
      var found_cr = false
      var found_nl = false
      line_beginnings.push((0, 0))

      var seg_index: USize = 0
      for seg in segments.values() do
        var char_index: USize = 0

        for ch in seg.values() do
          if ch == '\r' then
            if found_nl then
              line_beginnings.push((seg_index, char_index))
            end
            found_cr = true
            found_nl = false
          elseif ch == '\n' then
            found_cr = false
            found_nl = true
          else
            if found_nl then
              line_beginnings.push((seg_index, char_index))
            elseif found_cr then
              line_beginnings.push((seg_index, char_index))
            end
            found_cr = false
            found_nl = false
          end
          char_index = char_index + 1
        end
        seg_index = seg_index + 1
      end

      if found_cr or found_nl then
        try
          line_beginnings.push((seg_index - 1, segments(seg_index - 1)?.size()))
        end
      end
    end
    // _log(Fine) and _log.log("line beginnings:")
    // var i: USize = 1
    // for (seg, idx) in line_beginnings.values() do
    //   _log(Fine) and _log.log("  " + i.string() + ": " + seg.string() + ":" + idx.string())
    //   i = i + 1
    // end

  fun tag _get_canonical_path(auth: FileAuth, client_uri': String) : FilePath =>
    var path_name = StringUtil.url_decode(
      if client_uri'.compare_sub("file://", 7) == Equal then
        client_uri'.trim(7)
      else
        client_uri'
      end)
    ifdef windows then
      try
        if path_name(0)? == '/' then
          path_name = path_name.trim(1)
        end
      end
    end

    var file_path = FilePath(auth, path_name)
    try
      file_path = file_path.canonical()?
    end
    file_path
