use "cli"

primitive _Options
  fun str_stdio(): String => "stdio"
  fun str_socket(): String => "socket"
  fun str_port(): String => "port"

  fun apply(env: Env): _CliOptions ? =>
    let spec =
      recover val
        CommandSpec.parent(
          "eohippus_lsp",
          "Eohippus Pony Language Server",
          [],
          [ CommandSpec.leaf(str_stdio(), "Communicate via stdio", [], [])?
            CommandSpec.leaf(
              str_socket(),
              "Communicate via sockets",
              [ OptionSpec.string(str_port(), "port") ],
              [])?
            CommandSpec.leaf("version", "Print the program version", [], [])?
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

  new create(command': Command) =>
    match command'.fullname()
    | "eohippus_lsp/stdio" =>
      command = StdioCommand
      socket_port = ""
    | "eohippus_lsp/socket" =>
      command = SocketCommand
      socket_port = command'.option(_Options.str_port()).string()
    else
      command = VersionCommand
      socket_port = ""
    end
