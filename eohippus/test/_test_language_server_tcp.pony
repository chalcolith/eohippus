use "logger"
use "pony_test"
use "net"

use json = "../json"
use ls = "../language_server"
use rpc = "../language_server/rpc"

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

    let port = "43251"

    let server_notify =
      object iso is ls.ServerNotify
        var _conn: (TCPConnection | None) = None

        fun ref listening(s: ls.Server) =>
          h.log("ServerNotify: listening: connecting")
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
            _conn = TCPConnection(
              TCPConnectAuth(h.env.root),
              object iso is TCPConnectionNotify
                fun ref connected(conn: TCPConnection ref) =>
                  h.log("client connected; sending initialize message")
                  let str = recover val msg.get_string(false) end
                  let len = str.size()
                  conn.write(
                    "Content-Length:" + len.string() + "\r\n" +
                    "\r\n" +
                    str)
                fun ref connect_failed(conn: TCPConnection ref) =>
                  conn.dispose()
                  s.dispose()
                  h.fail("TCP connection failed")
                  h.complete(false)
                fun ref closed(conn: TCPConnection ref) =>
                  h.log("client closed")
              end,
              "",
              port)
          | let err: json.ParseError =>
            s.dispose()
            h.fail("invalid JSON at " + err.index.string() + ": " + err.message)
            h.complete(false)
          end

        fun ref initializing(s: ls.Server) =>
          h.log("ServerNotify: initializing: sending initialied notification")
          let msg_text =
            """
              {
                "jsonrpc": "2.0",
                "method": "initialized"
              }
            """
          match recover val json.Parse(msg_text) end
          | let msg: json.Object val =>
            match _conn
            | let conn: TCPConnection =>
              let str = recover val msg.get_string(false) end
              let len = str.size()
              conn.write(
                "Content-Length:" + len.string() + "\r\n" +
                "\r\n" +
                str)
            else
              s.dispose()
              h.fail("connection not established")
              h.complete(false)
            end
          | let err: json.ParseError =>
            dispose()
            s.dispose()
            h.fail("invalid JSON at " + err.index.string() + ": " + err.message)
            h.complete(false)
          end

        fun ref initialized(s: ls.Server) =>
          h.log("ServerNotify: initialized: disposing")
          dispose()
          s.dispose()

        fun ref exiting(code: I32) =>
          h.log("ServerNotify: exiting: complete true")
          h.complete(true)

        fun ref errored(s: ls.Server) =>
          dispose()
          s.dispose()
          h.fail("server errored")
          h.complete(false)

        fun ref sent_error(
          s: ls.Server,
          id: (I128 | String | None),
          code: I128,
          message: String)
        =>
          dispose()
          s.dispose()
          h.fail(
            "error for " + id.string() + ": " + code.string() + ": " + message)
          h.complete(false)

        fun ref dispose() =>
          match _conn
          | let conn: TCPConnection =>
            conn.dispose()
          end
      end

    let server = ls.EohippusServer(h.env, logger, consume server_notify)
    let handler = rpc.EohippusHandler.from_tcp(
      logger, server, TCPListenAuth(h.env.root), "", port)

    h.long_test(4_000_000_000)
