use "logger"
use "pony_test"

use json = "../json"
use ls = "../server"
use rpc = "../server/rpc"

use lsp = "lsp"

primitive _TestLanguageServer
  fun apply(test: PonyTest) =>
    test(_TestLanguageServerNotificationExitBeforeInitialize)
    test(_TestLanguageServerRequestInitialize)

class iso _TestLanguageServerNotificationExitBeforeInitialize is UnitTest
  fun name(): String =>
    "language_server/stream/notification/exit/before_initialize"
  fun exclusion_group(): String => "language_server"

  fun apply(h: TestHelper) =>
    let server_stdin = lsp.TestInputStream
    let server_stdout = lsp.TestOutputStream
    let server_stderr = lsp.TestOutputStream({(str) => h.log(str) })

    let logger =
      ifdef debug then
        Logger[String](Fine, server_stderr, {(s: String): String => s })
      else
        Logger[String](Error, server_stderr, {(s: String): String => s })
      end

    let server_notify =
      object iso is ls.ServerNotify
        fun ref listening(s: ls.Server) =>
          let msg_text =
            """
              {
                "jsonrpc": "2.0",
                "id": 1,
                "method": "exit"
              }
            """
          match recover val json.Parse(msg_text) end
          | let msg: json.Object val =>
            server_stdin.send_message(msg)
          | let err: json.ParseError =>
            h.fail("invalid JSON at " + err.index.string() + ": " + err.message)
            h.complete(false)
            s.dispose()
          end
        fun ref exiting(code: I32) =>
          if code == 1 then
            h.complete(true)
          else
            h.fail("server should not exit with code " + code.string())
            h.complete(false)
          end
      end

    let server = ls.EohippusServer(
      h.env, logger, ls.ServerConfig(None), consume server_notify)
    let handler = rpc.EohippusHandler.from_streams(
      logger, server, server_stdin, server_stdout)

    h.long_test(2_000_000_000)

class iso _TestLanguageServerRequestInitialize is UnitTest
  fun name(): String => "language_server/stream/request/initialize"
  fun exclusion_group(): String => "language_server"

  fun apply(h: TestHelper) =>
    let server_stdin = lsp.TestInputStream
    let server_stdout = lsp.TestOutputStream
    let server_stderr = lsp.TestOutputStream({(str) => h.log(str) })

    let logger =
      ifdef debug then
        Logger[String](Fine, server_stderr, {(s: String): String => s })
      else
        Logger[String](Error, server_stderr, {(s: String): String => s })
      end

    let server_notify =
      object iso is ls.ServerNotify
        fun ref listening(s: ls.Server) =>
          let msg_text =
            """
              {
                "jsonrpc": "2.0",
                "id": 1,
                "method": "initialize",
                "params": {
                  "processId": 1,
                  "clientInfo": {
                    "name": "_TestLanguageServerRequestInitialize"
                  },
                  "rootUri": null,
                  "capabilities": {
                    "general": {
                      "positionEncodings": [ "utf-8" ]
                    }
                  }
                }
              }
            """
          match recover val json.Parse(msg_text) end
          | let msg: json.Object val =>
            server_stdin.send_message(msg)
          | let err: json.ParseError =>
            h.fail("invalid JSON at " + err.index.string() + ": " + err.message)
            h.complete(false)
            s.dispose()
          end

        fun ref initializing(s: ls.Server) =>
          let msg_text =
            """
              {
                "jsonrpc": "2.0",
                "method": "initialized"
              }
            """
          match recover val json.Parse(msg_text) end
          | let msg: json.Object val =>
            server_stdin.send_message(msg)
          | let err: json.ParseError =>
            h.fail("invalid JSON at " + err.index.string() + ": " + err.message)
            h.complete(false)
            s.dispose()
          end

        fun ref initialized(s: ls.Server) =>
          h.complete(true)
          s.dispose()

        fun ref sent_error(
          s: ls.Server,
          id: (I128 | String | None),
          code: I128,
          message: String)
        =>
          h.fail(
            "error for " + id.string() + ": " + code.string() + ": " + message)
          h.complete(false)
          s.dispose()
      end

    let server = ls.EohippusServer(
      h.env, logger, ls.ServerConfig(None), consume server_notify)
    let handler = rpc.EohippusHandler.from_streams(
      logger, server, server_stdin, server_stdout)

    h.long_test(2_000_000_000)
