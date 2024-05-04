use "logger"
use "pony_test"
use "net"

use json = "../json"
use ls = "../server"
use rpc = "../server/rpc"

use lsp = "lsp"

primitive _TestLanguageServerTcp
  fun apply(test: PonyTest) =>
    test(_TestLanguageServerTcpRequestInitialize)

class iso _TestLanguageServerTcpRequestInitialize is UnitTest
  fun name(): String => "language_server/tcp/request/initialize"
  fun exclusion_group(): String => "language_server"

  fun apply(h: TestHelper) =>
    let server_stderr = lsp.TestOutputStream(
      {(str) =>
        let str' = str.clone()
        try
          if str'(str'.size() - 1)? == '\n' then
            str'.truncate(str'.size() - 1)
          end
          if str'(str'.size() - 1)? == '\r' then
            str'.truncate(str'.size() - 1)
          end
        end
        h.log(consume str')
      })

    let logger =
      ifdef debug then
        Logger[String](Fine, server_stderr, {(s: String): String => s })
      else
        Logger[String](Error, server_stderr, {(s: String): String => s })
      end

    let port = "63421"
    let tcp_listener = TCPListener(
      TCPListenAuth(h.env.root),
      object iso is TCPListenNotify
        fun ref connected(listen: TCPListener ref): TCPConnectionNotify iso^ =>
          h.log("client: connected")

          object iso is TCPConnectionNotify
            let _input_buf: String iso = String

            fun ref accepted(conn: TCPConnection ref) =>
              h.log("client: accepted, sending initialize")
              let initialize_message =
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
              let buf: String iso = String
              buf.append("Content-Length:")
              buf.append(initialize_message.size().string())
              buf.append("\r\n\r\n")
              buf.append(initialize_message)
              conn.write(consume buf)

            fun ref connect_failed(conn: TCPConnection ref) =>
              h.fail("client: connection failed")
              h.complete(false)

            fun ref auth_failed(conn: TCPConnection ref) =>
              h.fail("client: auth failed")
              h.complete(false)

            fun ref received(
              conn: TCPConnection ref,
              data: Array[U8] iso,
              times: USize)
              : Bool
            =>
              h.log("client: received " + data.size().string() + " bytes")
              _input_buf.append(consume data)
              if _input_buf.contains("positionEncoding") then
                h.log("client: sending initialized")
                let initialized_message =
                  """
                    {
                      "jsonrpc": "2.0",
                      "method": "initialized"
                    }
                  """
                let buf: String iso = String
                buf.append("Content-Length:")
                buf.append(initialized_message.size().string())
                buf.append("\r\n\r\n")
                buf.append(initialized_message)
                conn.write(consume buf)
              end
              true
          end

        fun ref not_listening(listen:TCPListener ref) =>
          h.fail("client: not listening")
          h.complete(false)
      end,
      "",
      port)

    let server_notify =
      object iso is ls.ServerNotify
        fun ref initialized(s: ls.Server) =>
          h.log("server: initialized: disposing")
          s.dispose()

        fun ref exiting(code: I32) =>
          h.log("server: exiting")
          h.assert_eq[I32](0, code, "server exit code should be 0")
          h.complete(true)
          tcp_listener.dispose()

        fun ref errored(s: ls.Server) =>
          s.dispose()
          h.fail("server: errored")
          h.complete(false)
          tcp_listener.dispose()

        fun ref sent_error(
          s: ls.Server,
          id: (I128 | String | None),
          code: I128,
          message: String)
        =>
          h.fail("server: sent error for " + id.string() + ": " + code.string())
          s.dispose()
          h.fail(
            "error for " + id.string() + ": " + code.string() + ": " + message)
          h.complete(false)
          tcp_listener.dispose()
      end

    let server = ls.EohippusServer(h.env, logger, consume server_notify)
    let handler = rpc.EohippusHandler.from_tcp(
      logger, server, TCPConnectAuth(h.env.root), "", port)

    h.long_test(4_000_000_000)
