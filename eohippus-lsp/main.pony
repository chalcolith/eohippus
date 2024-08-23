use "logger"
use "net"

use "../eohippus"
use ls = "../eohippus/server"
use rpc = "../eohippus/server/rpc"

actor Main
  new create(env: Env) =>
    ifdef debug then
      let buf: String trn = String
      buf.append("eohippus-lsp")
      for arg in env.args.values() do
        buf.append(" ")
        buf.append(arg)
      end
      env.err.print(consume buf)
    end

    let options =
      try
        _Options(env)?
      else
        env.exitcode(1)
        return
      end

    let logger =
      ifdef debug then
        Logger[String](
          Fine, env.err, {(s: String): String => s }, _LogFormatter)
      else
        Logger[String](
          Error, env.err, {(s: String): String => s }, _LogFormatter)
      end

    let config = recover val ls.ServerConfig(options.ponyc_executable) end

    match options.command
    | StdioCommand =>
      let server = ls.EohippusServer(env, logger, config)
      let handler = rpc.EohippusHandler.from_streams(
        logger, server, env.input, env.out)
    | SocketCommand =>
      let server = ls.EohippusServer(env, logger, config)
      let handler = rpc.EohippusHandler.from_tcp(
        logger, server, TCPConnectAuth(env.root), "", options.socket_port)
    | VersionCommand =>
      env.out.print("eohippus_lsp version " + Version())
      env.out.print("Copyright (c) The Eohippus Developers")
    end
