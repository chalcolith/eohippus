use "cli"

class val _CliOptions
  let target_path: String
  let fix: Bool
  let verbose: Bool

  new create(command: Command) =>
    target_path = command.arg(_BuildCliOptions._str_target_path()).string()
    fix = command.option(_BuildCliOptions._str_fix()).bool()
    verbose = command.option(_BuildCliOptions._str_verbose()).bool()

  new val default() =>
    target_path = "."
    fix = true
    verbose = false

primitive _BuildCliOptions
  fun _str_target_path(): String => "target_path"
  fun _str_fix(): String => "fix"
  fun _str_verbose(): String => "verbose"

  fun apply(env: Env): _CliOptions ? =>
    let spec =
      recover val
        CommandSpec.leaf("fmt", "Formatting tool for Pony files",
          [ OptionSpec.bool(
              _str_fix(), "Fix formatting issues in files"
              where short' = 'f', default' = true)
            OptionSpec.bool(
              _str_verbose(), "Print extra information during processing"
              where short' = 'v', default' = false )],
          [ ArgSpec.string(
              _str_target_path(), "File or directory to format"
              where default' = ".")
          ])? .> add_help()?
      end

    recover val
      match CommandParser(spec).parse(env.args, env.vars)
      | let command: Command =>
        _CliOptions(command)
      | let help: CommandHelp =>
        help.print_help(env.err)
        env.exitcode(0)
        error
      | let syntax_error: SyntaxError =>
        env.err.print(syntax_error.string())
        env.exitcode(1)
        error
      end
    end
