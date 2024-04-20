use "logger"
use "pony_test"

use json = "../json"
use ls = "../language_server"
use rpc = "../language_server/rpc"

use lsp = "lsp"

primitive _TestLanguageServer
  fun apply(test: PonyTest) =>
    test(_TestLanguageServerExitBeforeInitialize)

class iso _TestLanguageServerExitBeforeInitialize is UnitTest
  fun name(): String => "language_server/exit_before_initialize"
  fun exclusion_group(): String => "language_server"

  fun apply(h: TestHelper) =>
    let helper = lsp.Helper(
      h,
      {(buf_stdout: String) =>
        if buf_stdout.contains("id:1") then
          h.complete(true)
        end
      },
      {(buf_stderr: String) =>
        if buf_stderr.contains("Error") then
          h.complete(false)
        end
      })

    let message =
      recover val
        json.Object(
          [ as (String, json.Item):
            ("jsonrpc", "2.0")
            ("id", I128(1))
            ("method", "exit") ])
      end
    helper.send_message(message)

    h.long_test(2_000_000_000)
