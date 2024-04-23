use "logger"
use "pony_test"

use json = "../../json"
use ls = "../../language_server"
use rpc = "../../language_server/rpc"

interface iso _StreamNotify
  fun ref apply(buf: String)

actor Helper is TestOutputNotify
  let stdin: TestInputStream
  let stdout: TestOutputStream
  let stderr: TestOutputStream
  let logger: Logger[String]
  let server: ls.Server
  let handler: rpc.Handler

  let _notify_stdout: _StreamNotify
  let _notify_stderr: _StreamNotify

  let stdout_buffer: String ref = String
  let stderr_buffer: String ref = String

  new create(
    h: TestHelper,
    server_stdin: TestInputStream,
    notify_stdout: _StreamNotify,
    notify_stderr: _StreamNotify,
    server_notify: ls.ServerNotify)
  =>
    stdin = server_stdin
    stdout = TestOutputStream(this)
    stderr = TestOutputStream(this)

    logger =
      ifdef debug then
        Logger[String](Fine, stderr, { (s: String): String => s })
      else
        Logger[String](Error, stderr, { (s: String): String => s })
      end
    let self = this
    server = ls.EohippusServer(h.env, logger, server_notify)
    handler = rpc.EohippusHandler.from_streams(logger, server, stdin, stdout)

    _notify_stdout = consume notify_stdout
    _notify_stderr = consume notify_stderr

  be write_output(stream: TestOutputStream tag, str: String) =>
    if stream is stdout then
      stdout_buffer.append(str)
      _notify_stdout(str)
    elseif stream is stderr then
      stderr_buffer.append(str)
      _notify_stderr(str)
    end
