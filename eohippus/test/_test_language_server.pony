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
      {(helper: lsp.Helper) =>
        let message =
          recover val
            json.Object(
              [ as (String, json.Item):
                ("jsonrpc", "2.0")
                ("id", I128(1))
                ("method", "exit") ])
          end
        helper.send_message(message)
      })

    h.long_test(2_000_000_000)
