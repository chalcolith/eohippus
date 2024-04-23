use "logger"
use "pony_test"

use json = "../json"
use ls = "../language_server"
use rpc = "../language_server/rpc"

use lsp = "lsp"

primitive _TestLanguageServer
  fun apply(test: PonyTest) =>
    test(_TestLanguageServerNotificationExitBeforeInitialize)
    test(_TestLanguageServerRequestInitialize)

class iso _TestLanguageServerNotificationExitBeforeInitialize is UnitTest
  fun name(): String => "language_server/notification/exit/before_initialize"
  fun exclusion_group(): String => "language_server"

  fun apply(h: TestHelper) =>
    let server_stdin = lsp.TestInputStream
    let helper = lsp.Helper(
      h,
      server_stdin,
      { ref (buf: String) =>
        h.fail("there should not be a response from the server")
        h.complete(false)
      },
      object iso
        var ungraceful_exit: Bool = false
        fun ref apply(buf: String) =>
          h.log(buf)
          if buf.contains("ungraceful exit requested") then
            ungraceful_exit = true
          elseif buf.contains("server exiting with code") then
            if buf.contains("server exiting with code 1") then
              if not ungraceful_exit then
                h.fail("server did not exit ungracefully")
              end
            elseif buf.contains("server exiting with code 0") then
              h.fail("server should not exit with code 0")
            end
            h.complete(true)
          end
      end,
      object val is ls.ServerNotify
        fun connected() =>
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
          end
      end)

    h.long_test(2_000_000_000)

class iso _TestLanguageServerRequestInitialize is UnitTest
  fun name(): String => "language_server/request/initialize"
  fun exclusion_group(): String => "language_server"

  fun apply(h: TestHelper) =>
    let server_stdin = lsp.TestInputStream

    let notify =
      object val is ls.ServerNotify
        fun connected() =>
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
          end

        fun initializing() =>
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
          end

        fun initialized() =>
          h.complete(true)

        fun sent_error(
          id: (I128 | String | None),
          code: I128,
          message: String)
        =>
          h.fail(
            "error for " + id.string() + ": " + code.string() + ": " + message)
          h.complete(false)
      end

    let helper = lsp.Helper(
      h,
      server_stdin,
      { ref (buf: String) => None },
      { ref (buf: String) => h.log(buf) },
      notify)

    h.long_test(2_000_000_000)
