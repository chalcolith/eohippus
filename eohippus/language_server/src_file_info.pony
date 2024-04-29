use "files"
use "logger"

use ast = "../ast"
use prsr = "../parser"
use ".."

class SrcFileInfo
  let _log: Logger[String]
  let _server: Server

  let client_uri: String
  let canonical_file_path: FilePath

  var is_open_in_client: Bool = false
  var is_parsing: Bool = false
  var parse_task_id: USize = 0
  var segments: Array[String] val = []
  var parser: (prsr.Parser | None) = None
  var syntax_tree: (ast.SyntaxTree | None) = None

  new create(
    log: Logger[String],
    server: Server,
    auth: FileAuth,
    client_uri': String)
  =>
    _log = log
    _server = server
    client_uri = client_uri'
    canonical_file_path = _get_canonical_file_path(auth, client_uri')

  fun ref parse_full(task_id: USize, grammar: prsr.Builder val, text: String) =>
    _log(Fine) and _log.log("starting parse for " + canonical_file_path.path)
    is_parsing = true
    parse_task_id = task_id
    segments = [ text ]
    syntax_tree = None

    let path = canonical_file_path.path
    let parser' = prsr.Parser(segments)
    parser = parser'
    parser'.parse(
      grammar.src_file.src_file,
      prsr.Data(canonical_file_path.path),
      {(result: (prsr.Success | prsr.Failure), values: ast.NodeSeq) =>
        match result
        | let success: prsr.Success =>
          try
            match values(0)?
            | let node: ast.NodeWith[ast.SrcFile] =>
              _server.parse_succeeded(task_id, path, node)
            else
              _log(Error) and _log.log(
                "parse result was not SrcFile for " + path)
            end
          else
            _log(Error) and _log.log(
              "failed to get SrcFile result from parsing " + path)
          end
        | let failure: prsr.Failure =>
          _log(Error) and _log.log("failed to parse " + path + ": " +
            failure.get_message())
        end
      })

  fun ref finish_parse(node: ast.NodeWith[ast.SrcFile]) =>
    is_parsing = false
    syntax_tree = ast.SyntaxTree(node)

  fun tag _get_canonical_file_path(auth: FileAuth, client_uri': String)
    : FilePath
  =>
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
