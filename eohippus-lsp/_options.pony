use "cli"

primitive _Options
  fun str_stdio(): String => "stdio"
  fun str_socket(): String => "socket"
  fun str_version(): String => "version"
  fun str_ponyc_executable(): String => "ponycExecutable"

  fun apply(env: Env): _CliOptions ? =>
    let spec =
      recover val
        CommandSpec.leaf(
          "eohippus-lsp",
          "Eohippus Pony Language Server",
          [ OptionSpec.bool(
              str_stdio(), "Communicate via stdio" where default'=false)
            OptionSpec.string(
              str_socket(), "Communication via socket" where default'="")
            OptionSpec.bool(
              str_version(), "Print the program version" where default'=true)
            OptionSpec.string(
              str_ponyc_executable(), "Path of the ponyc executable"
              where default'="")
          ])?
          .> add_help()?
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

primitive StdioCommand
primitive SocketCommand
primitive VersionCommand

type LspCommand is (StdioCommand | SocketCommand | VersionCommand)

class val _CliOptions
  let command: LspCommand
  let socket_port: String
  let ponyc_executable: (String | None)

  new create(command': Command) =>
    let ponyc_executable' = command'.option(_Options.str_ponyc_executable())
      .string()
    ponyc_executable =
      if ponyc_executable' != "" then
        ponyc_executable'
      end

    if command'.option(_Options.str_stdio()).bool() then
      command = StdioCommand
      socket_port = ""
    else
      let socket = command'.option(_Options.str_socket()).string()
      if socket != "" then
        command = SocketCommand
        socket_port = socket
      else
        command = VersionCommand
        socket_port = ""
      end
    end
