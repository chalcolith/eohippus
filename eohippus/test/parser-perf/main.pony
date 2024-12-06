use "files"
use "time"

use ast = "../../ast"
use parser = "../../parser"

actor Main
  let _env: Env

  var num_files: USize = 0
  var start_sec: I64 = 0
  var start_nanos: I64 = 0
  var end_sec: I64 = 0
  var end_nanos: I64 = 0

  new create(env: Env) =>
    _env = env
    (start_sec, start_nanos) = Time.now()
    let self: Main tag = this
    let builder: parser.Builder val = parser.Builder(parser.Context([]))
    for arg in env.args.values() do
      if not (arg.size() > 5) then continue end
      if not
        (arg.compare_sub(".pony", 5, ISize.from[USize](arg.size()) - 5) is Equal)
      then
        continue
      end

      let fp = FilePath(FileAuth(env.root), arg)
      if fp.exists() then
        match OpenFile(fp)
        | let file: File =>
          env.err.print("parsing " + arg)
          num_files = num_files + 1
          let data = file.read_string(file.size())
          let segs: Array[String] val = [ consume data ]
          let rule = builder.src_file.src_file
          let parse = parser.Parser(segs)
          parse.parse(
            rule,
            parser.Data(arg),
            {(result: parser.Result, values: ast.NodeSeq) =>
              match result
              | let success: parser.Success =>
                _env.out.print(arg + " succeeded")
              | let failure: parser.Failure =>
                _env.out.print(arg + " failed: " + failure.get_message())
              end
              self.print_time()
            })
        else
          env.err.print("unable to open " + arg)
        end
      else
        env.err.print(arg + " does not exist")
      end
    end

  be print_time() =>
    if num_files > 0 then
      num_files = num_files - 1
    end
    if num_files == 0 then
      (end_sec, end_nanos) = Time.now()

      let total_nanos: I128 =
        ((I128.from[I64](end_sec) * 1_000_000_000) + I128.from[I64](end_nanos)) -
        ((I128.from[I64](start_sec) * 1_000_000_000) + I128.from[I64](start_nanos))

      let secs = total_nanos / 1_000_000_000
      let nanos = total_nanos % 1_000_000_000
      _env.out.print(secs.string() + " secs, " + nanos.string() + " nanos")
    end
